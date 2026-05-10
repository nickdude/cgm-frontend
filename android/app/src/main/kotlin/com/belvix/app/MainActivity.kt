package com.belvix.app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	private lateinit var cgmBridge: CgmSdkBridge

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		cgmBridge = CgmSdkBridge(this)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			CgmSdkBridge.METHOD_CHANNEL
		).setMethodCallHandler(::onMethodCall)

		EventChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			CgmSdkBridge.EVENT_CHANNEL
		).setStreamHandler(
			object : EventChannel.StreamHandler {
				override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
					cgmBridge.setEventSink(events)
				}

				override fun onCancel(arguments: Any?) {
					cgmBridge.setEventSink(null)
				}
			}
		)
	}

	private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"requestBlePermissions" -> cgmBridge.requestBluetoothPermissions(result)
			"authorize" -> {
				val appId = call.argument<String>("appId")
				val appSecret = call.argument<String>("appSecret")
				if (appId.isNullOrBlank() || appSecret.isNullOrBlank()) {
					result.error("INVALID_ARGS", "appId and appSecret are required", null)
					return
				}
				cgmBridge.authorize(appId, appSecret, result)
			}

			"connect" -> {
				val sensorSn = call.argument<String>("sensorSn")
				if (sensorSn.isNullOrBlank()) {
					result.error("INVALID_ARGS", "sensorSn is required", null)
					return
				}
				cgmBridge.connect(sensorSn, result)
			}

			"getHistoryFromIndexStart" -> {
				val sensorSn = call.argument<String>("sensorSn")
				val indexStart = call.argument<Int>("indexStart")
				if (sensorSn.isNullOrBlank() || indexStart == null) {
					result.error("INVALID_ARGS", "sensorSn and indexStart are required", null)
					return
				}
				cgmBridge.getHistoryFromIndexStart(sensorSn, indexStart, result)
			}

			"getHistoryFromTimeRange" -> {
				val sensorSn = call.argument<String>("sensorSn")
				val startTimeSeconds = call.argument<Number>("startTimeSeconds")
				val endTimeSeconds = call.argument<Number>("endTimeSeconds")
				if (sensorSn.isNullOrBlank() || startTimeSeconds == null || endTimeSeconds == null) {
					result.error("INVALID_ARGS", "sensorSn, startTimeSeconds and endTimeSeconds are required", null)
					return
				}
				cgmBridge.getHistoryFromTimeRange(
					sensorSn,
					startTimeSeconds.toLong(),
					endTimeSeconds.toLong(),
					result
				)
			}

			"disconnect" -> cgmBridge.disconnect(result)
			"isConnected" -> cgmBridge.isConnected(result)
			else -> result.notImplemented()
		}
	}

	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray
	) {
		if (!cgmBridge.onRequestPermissionsResult(requestCode, grantResults)) {
			super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		}
	}
}
