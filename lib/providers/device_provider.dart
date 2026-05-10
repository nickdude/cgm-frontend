import 'package:flutter/foundation.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';

class DeviceProvider extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();

  List<Device> _devices = [];
  Device? _selectedDevice;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _deviceData;

  List<Device> get devices => _devices;
  Device? get selectedDevice => _selectedDevice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get deviceData => _deviceData;

  /// Load all devices
  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _devices = await _deviceService.getAllDevices();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load specific device by serial number
  Future<void> loadDevice(String serialNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDevice = await _deviceService.getDeviceBySerialNumber(serialNumber);
      if (_selectedDevice == null) {
        _error = 'Device not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Disconnect a device
  Future<bool> disconnectDevice(String serialNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _deviceService.disconnectDevice(serialNumber);
      if (result) {
        // Reload devices after disconnection
        await loadDevices();
        return true;
      } else {
        _error = 'Failed to disconnect device';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get device data/history
  Future<void> loadDeviceData(String serialNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deviceData = await _deviceService.getDeviceData(serialNumber);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear selected device
  void clearSelectedDevice() {
    _selectedDevice = null;
    _deviceData = null;
    notifyListeners();
  }
}
