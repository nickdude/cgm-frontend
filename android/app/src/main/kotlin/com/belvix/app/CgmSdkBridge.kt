package com.belvix.app

import android.Manifest
import android.app.Application
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Proxy

class CgmSdkBridge(private val activity: FlutterActivity) {
    companion object {
        const val METHOD_CHANNEL = "com.belvix.app/cgm/methods"
        const val EVENT_CHANNEL = "com.belvix.app/cgm/events"
        private const val REQUEST_CODE_PERMISSIONS = 18117

        fun initSdk(application: Application) {
            runCatching {
                val manager = getManagerInstance() ?: return
                val initMethod = manager.javaClass.methods.firstOrNull {
                    it.name == "init" && it.parameterTypes.size == 1
                } ?: return
                initMethod.invoke(manager, application)
            }
        }

        private fun getManagerClass(): Class<*>? {
            val candidates = listOf(
                "com.eaglenos.blehealth.cgm.CgmDeviceManager",
                "com.eaglenos.blehealth.CgmDeviceManager",
                "com.eaglenos.blehealth.manager.CgmDeviceManager"
            )

            for (name in candidates) {
                val clazz = runCatching { Class.forName(name) }.getOrNull()
                if (clazz != null) {
                    return clazz
                }
            }
            return null
        }

        private fun getManagerInstance(): Any? {
            val managerClass = getManagerClass() ?: return null
            val getInstanceMethod = managerClass.methods.firstOrNull {
                it.name == "getInstance" && it.parameterTypes.isEmpty()
            } ?: return null
            return getInstanceMethod.invoke(null)
        }
    }

    private var eventSink: EventChannel.EventSink? = null
    private var permissionResult: MethodChannel.Result? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun requestBluetoothPermissions(result: MethodChannel.Result) {
        if (hasAllPermissions()) {
            result.success(true)
            return
        }

        permissionResult = result
        ActivityCompat.requestPermissions(
            activity,
            requiredPermissions(),
            REQUEST_CODE_PERMISSIONS
        )
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_CODE_PERMISSIONS) {
            return false
        }

        val callback = permissionResult
        permissionResult = null
        if (callback == null) {
            return true
        }

        val allGranted = grantResults.isNotEmpty() && grantResults.all {
            it == PackageManager.PERMISSION_GRANTED
        }

        callback.success(allGranted)
        sendEvent(
            mapOf(
                "type" to "permission",
                "granted" to allGranted
            )
        )
        return true
    }

    fun authorize(appId: String, appSecret: String, result: MethodChannel.Result) {
        val manager = getManagerInstance()
        if (manager == null) {
            result.error(
                "SDK_MISSING",
                "CGM SDK (bleHealth-release.aar) not found in android/app/libs. Copy the AAR there and rebuild.",
                null
            )
            return
        }

        val checkAuthorizedMethod = manager.javaClass.methods.firstOrNull {
            it.name == "checkAuthorized" && it.parameterTypes.isEmpty()
        }

        val alreadyAuthorized = runCatching {
            (checkAuthorizedMethod?.invoke(manager) as? Boolean) == true
        }.getOrDefault(false)

        if (alreadyAuthorized) {
            result.success(true)
            return
        }

        val authMethod = manager.javaClass.methods.firstOrNull {
            it.name == "authCert" && it.parameterTypes.size == 3
        }

        if (authMethod == null) {
            result.error("SDK_API_MISSING", "authCert API not found in CGM SDK.", null)
            return
        }

        val callbackInterface = authMethod.parameterTypes[2]
        val callback = Proxy.newProxyInstance(
            callbackInterface.classLoader,
            arrayOf(callbackInterface),
            InvocationHandler { _, method, args ->
                when (method.name) {
                    "onSuccess" -> {
                        result.success(true)
                        sendEvent(mapOf("type" to "auth", "success" to true))
                    }

                    "onError" -> {
                        val message = args?.firstOrNull()?.toString() ?: "SDK authorization failed"
                        result.error("SDK_AUTH_FAILED", message, null)
                        sendEvent(
                            mapOf(
                                "type" to "auth",
                                "success" to false,
                                "error" to message
                            )
                        )
                    }
                }
                null
            }
        )

        runCatching {
            authMethod.invoke(manager, appId, appSecret, callback)
        }.onFailure {
            result.error("SDK_AUTH_EXCEPTION", it.message, null)
        }
    }

    fun connect(sensorSn: String, result: MethodChannel.Result) {
        val manager = getManagerInstance()
        if (manager == null) {
            result.error(
                "SDK_MISSING",
                "CGM SDK (bleHealth-release.aar) not found in android/app/libs. Copy the AAR there and rebuild.",
                null
            )
            return
        }

        registerBindStepCallback(manager)
        registerSyncProgressCallback(manager)
        registerSdkLogCallback(manager)

        val registerStateMethod = manager.javaClass.methods.firstOrNull {
            it.name == "setCgmDeviceStateInfoCallback" && it.parameterTypes.size == 1
        }

        val stateCallbackType = registerStateMethod?.parameterTypes?.firstOrNull()
        if (registerStateMethod != null && stateCallbackType != null) {
            val stateCallback = Proxy.newProxyInstance(
                stateCallbackType.classLoader,
                arrayOf(stateCallbackType),
                InvocationHandler { _, method, args ->
                    when (method.name) {
                        "onFailed" -> {
                            sendEvent(
                                mapOf(
                                    "type" to "device_error",
                                    "error" to (args?.firstOrNull()?.toString() ?: "Unknown error")
                                )
                            )
                        }

                        "onDeviceInfoReceived" -> {
                            val info = args?.firstOrNull()
                            sendEvent(
                                mapOf(
                                    "type" to "device_info",
                                    "payload" to toMap(info)
                                )
                            )
                        }

                        "onGlucoseDataWithErrorReceived" -> {
                            val bloodSugars = args?.getOrNull(3)
                            val glucosePayload = extractList(bloodSugars).map { toMap(it) }
                            sendEvent(
                                mapOf(
                                    "type" to "glucose_data",
                                    "payload" to glucosePayload
                                )
                            )
                        }
                    }
                    null
                }
            )

            runCatching {
                registerStateMethod.invoke(manager, stateCallback)
            }
        }

        val connectMethod = manager.javaClass.methods.firstOrNull {
            it.name == "connectTargetAndStartScan" && it.parameterTypes.size == 3
        } ?: manager.javaClass.methods.firstOrNull {
            it.name == "connectTargetDevice" && it.parameterTypes.size == 3
        }

        if (connectMethod == null) {
            result.error("SDK_API_MISSING", "connectTargetDevice/connectTargetAndStartScan API not found.", null)
            return
        }

        val callbackType = connectMethod.parameterTypes[2]
        val connectCallback = Proxy.newProxyInstance(
            callbackType.classLoader,
            arrayOf(callbackType),
            InvocationHandler { _, method, args ->
                when (method.name) {
                    "onSuccess" -> {
                        result.success(true)
                        sendEvent(
                            mapOf(
                                "type" to "connection",
                                "connected" to true
                            )
                        )
                    }

                    "onFailure" -> {
                        val error = args?.firstOrNull()?.toString() ?: "CGM connect failed"
                        result.error("CGM_CONNECT_FAILED", error, null)
                        sendEvent(
                            mapOf(
                                "type" to "connection",
                                "connected" to false,
                                "error" to error
                            )
                        )
                    }

                    "onDeviceDisconnected" -> {
                        sendEvent(
                            mapOf(
                                "type" to "connection",
                                "connected" to false,
                                "reason" to "disconnected"
                            )
                        )
                    }
                }
                null
            }
        )

        runCatching {
            connectMethod.invoke(manager, sensorSn, false, connectCallback)
        }.onFailure {
            result.error("CGM_CONNECT_EXCEPTION", it.message, null)
        }
    }

    fun getHistoryFromIndexStart(sensorSn: String, indexStart: Int, result: MethodChannel.Result) {
        val manager = getManagerInstance()
        if (manager == null) {
            result.error(
                "SDK_MISSING",
                "CGM SDK (bleHealth-release.aar) not found in android/app/libs. Copy the AAR there and rebuild.",
                null
            )
            return
        }

        val historyMethod = manager.javaClass.methods.firstOrNull {
            it.name == "getHistoryFromIndexStart" && it.parameterTypes.size == 3
        }

        if (historyMethod == null) {
            result.error("SDK_API_MISSING", "getHistoryFromIndexStart API not found.", null)
            return
        }

        val callbackType = historyMethod.parameterTypes[2]
        val callback = Proxy.newProxyInstance(
            callbackType.classLoader,
            arrayOf(callbackType),
            InvocationHandler { _, method, args ->
                when (method.name) {
                    "onSyncHistorySuccess" -> {
                        val list = extractList(args?.firstOrNull()).map { toMap(it) }
                        sendEvent(mapOf("type" to "history_data", "payload" to list))
                        result.success(list)
                    }

                    "onSyncHistoryFailed" -> {
                        val message = args?.firstOrNull()?.toString() ?: "History sync failed"
                        result.error("CGM_HISTORY_FAILED", message, null)
                        sendEvent(mapOf("type" to "device_error", "error" to message))
                    }
                }
                null
            }
        )

        runCatching {
            historyMethod.invoke(manager, sensorSn, indexStart, callback)
        }.onFailure {
            result.error("CGM_HISTORY_EXCEPTION", it.message, null)
        }
    }

    fun getHistoryFromTimeRange(
        sensorSn: String,
        startTimeSeconds: Long,
        endTimeSeconds: Long,
        result: MethodChannel.Result
    ) {
        val manager = getManagerInstance()
        if (manager == null) {
            result.error(
                "SDK_MISSING",
                "CGM SDK (bleHealth-release.aar) not found in android/app/libs. Copy the AAR there and rebuild.",
                null
            )
            return
        }

        val historyMethod = manager.javaClass.methods.firstOrNull {
            it.name == "getHistoryFromTimeRange" && it.parameterTypes.size == 4
        }

        if (historyMethod == null) {
            result.error("SDK_API_MISSING", "getHistoryFromTimeRange API not found.", null)
            return
        }

        val callbackType = historyMethod.parameterTypes[3]
        val callback = Proxy.newProxyInstance(
            callbackType.classLoader,
            arrayOf(callbackType),
            InvocationHandler { _, method, args ->
                when (method.name) {
                    "onSyncHistorySuccess" -> {
                        val list = extractList(args?.firstOrNull()).map { toMap(it) }
                        sendEvent(mapOf("type" to "history_data", "payload" to list))
                        result.success(list)
                    }

                    "onSyncHistoryFailed" -> {
                        val message = args?.firstOrNull()?.toString() ?: "History sync failed"
                        result.error("CGM_HISTORY_FAILED", message, null)
                        sendEvent(mapOf("type" to "device_error", "error" to message))
                    }
                }
                null
            }
        )

        runCatching {
            historyMethod.invoke(manager, sensorSn, startTimeSeconds, endTimeSeconds, callback)
        }.onFailure {
            result.error("CGM_HISTORY_EXCEPTION", it.message, null)
        }
    }

    fun disconnect(result: MethodChannel.Result) {
        val manager = getManagerInstance()
        if (manager == null) {
            result.error(
                "SDK_MISSING",
                "CGM SDK (bleHealth-release.aar) not found in android/app/libs. Copy the AAR there and rebuild.",
                null
            )
            return
        }

        val method = manager.javaClass.methods.firstOrNull {
            it.name == "disconnectDevice" && it.parameterTypes.isEmpty()
        }

        if (method == null) {
            result.error("SDK_API_MISSING", "disconnectDevice API not found.", null)
            return
        }

        runCatching {
            method.invoke(manager)
            sendEvent(mapOf("type" to "connection", "connected" to false))
            result.success(true)
        }.onFailure {
            result.error("CGM_DISCONNECT_EXCEPTION", it.message, null)
        }
    }

    fun isConnected(result: MethodChannel.Result) {
        val manager = getManagerInstance()
        if (manager == null) {
            result.error(
                "SDK_MISSING",
                "CGM SDK (bleHealth-release.aar) not found in android/app/libs. Copy the AAR there and rebuild.",
                null
            )
            return
        }

        val method = manager.javaClass.methods.firstOrNull {
            it.name == "isConnected" && it.parameterTypes.isEmpty()
        }

        if (method == null) {
            result.error("SDK_API_MISSING", "isConnected API not found.", null)
            return
        }

        runCatching {
            val connected = (method.invoke(manager) as? Boolean) == true
            result.success(connected)
        }.onFailure {
            result.error("CGM_STATE_EXCEPTION", it.message, null)
        }
    }

    private fun hasAllPermissions(): Boolean {
        return requiredPermissions().all { permission ->
            ActivityCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun registerBindStepCallback(manager: Any) {
        val method = manager.javaClass.methods.firstOrNull {
            it.name == "setCgmBindStepCallback" && it.parameterTypes.size == 1
        } ?: return

        val callbackType = method.parameterTypes[0]
        val callback = Proxy.newProxyInstance(
            callbackType.classLoader,
            arrayOf(callbackType),
            InvocationHandler { _, callbackMethod, args ->
                if (callbackMethod.name == "onResult") {
                    val step = args?.firstOrNull()?.toString().orEmpty()
                    sendEvent(mapOf("type" to "binding_step", "step" to step))
                }
                null
            }
        )

        runCatching { method.invoke(manager, callback) }
    }

    private fun registerSyncProgressCallback(manager: Any) {
        val method = manager.javaClass.methods.firstOrNull {
            it.name == "setCgmDeviceDataSyncProgressCallback" && it.parameterTypes.size == 1
        } ?: return

        val callbackType = method.parameterTypes[0]
        val callback = Proxy.newProxyInstance(
            callbackType.classLoader,
            arrayOf(callbackType),
            InvocationHandler { _, callbackMethod, args ->
                if (callbackMethod.name == "onProgress") {
                    val progress = (args?.firstOrNull() as? Number)?.toInt() ?: 0
                    sendEvent(mapOf("type" to "sync_progress", "progress" to progress))
                }
                null
            }
        )

        runCatching { method.invoke(manager, callback) }
    }

    private fun registerSdkLogCallback(manager: Any) {
        val method = manager.javaClass.methods.firstOrNull {
            it.name == "setCgmLogCallback" && it.parameterTypes.size == 1
        } ?: return

        val callbackType = method.parameterTypes[0]
        val callback = Proxy.newProxyInstance(
            callbackType.classLoader,
            arrayOf(callbackType),
            InvocationHandler { _, callbackMethod, args ->
                if (callbackMethod.name == "onPrint") {
                    val message = args?.firstOrNull()?.toString().orEmpty()
                    sendEvent(mapOf("type" to "sdk_log", "message" to message))
                }
                null
            }
        )

        runCatching { method.invoke(manager, callback) }
    }

    private fun requiredPermissions(): Array<String> {
        val permissions = mutableListOf<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions += Manifest.permission.BLUETOOTH_SCAN
            permissions += Manifest.permission.BLUETOOTH_CONNECT
        } else {
            permissions += Manifest.permission.BLUETOOTH
            permissions += Manifest.permission.BLUETOOTH_ADMIN
            permissions += Manifest.permission.ACCESS_FINE_LOCATION
            permissions += Manifest.permission.ACCESS_COARSE_LOCATION
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                permissions += Manifest.permission.ACCESS_BACKGROUND_LOCATION
            }
        }

        return permissions.toTypedArray()
    }

    private fun sendEvent(payload: Map<String, Any?>) {
        activity.runOnUiThread {
            eventSink?.success(payload)
        }
    }

    private fun extractList(value: Any?): List<Any?> {
        return when (value) {
            is List<*> -> value
            else -> emptyList()
        }
    }

    private fun toMap(instance: Any?): Map<String, Any?> {
        if (instance == null) {
            return emptyMap()
        }

        return runCatching {
            instance.javaClass.declaredFields.associate { field ->
                field.isAccessible = true
                field.name to sanitizeValue(field.get(instance))
            }
        }.getOrDefault(emptyMap())
    }

    private fun sanitizeValue(value: Any?): Any? {
        return when (value) {
            null -> null
            is String, is Number, is Boolean -> value
            is List<*> -> value.map { sanitizeValue(it) }
            is Map<*, *> -> value.entries.associate { (k, v) ->
                k.toString() to sanitizeValue(v)
            }
            else -> value.toString()
        }
    }
}
