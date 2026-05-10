import '../models/device_model.dart';

class DeviceService {
  // Mock devices data
  static final List<Map<String, dynamic>> _mockDevicesData = [
    {
      'serialNumber': '62600024',
      'activationTime': '2026-02-27 16:42',
      'usageTime': '--',
      'endTime': '-----',
      'status': 'In Use',
      'isActive': true,
    },
    {
      'serialNumber': '53200068',
      'activationTime': '2026-02-27 16:42',
      'usageTime': '1Days1Hours',
      'endTime': '2026-02-27 16:42',
      'status': 'Ended',
      'isActive': false,
    },
    {
      'serialNumber': '53200071',
      'activationTime': '2026-02-26 10:25',
      'usageTime': '4Hours',
      'endTime': '2026-02-26 14:49',
      'status': 'Ended',
      'isActive': false,
    },
    {
      'serialNumber': '51800008',
      'activationTime': '2025-12-19 18:39',
      'usageTime': '13Hours',
      'endTime': '2025-12-20 08:00',
      'status': 'Ended',
      'isActive': false,
    },
  ];

  /// Fetch all devices
  Future<List<Device>> getAllDevices() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockDevicesData
        .map((data) => Device.fromJson(data))
        .toList();
  }

  /// Fetch device by serial number
  Future<Device?> getDeviceBySerialNumber(String serialNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final data = _mockDevicesData.firstWhere(
      (device) => device['serialNumber'] == serialNumber,
      orElse: () => {},
    );

    if (data.isEmpty) return null;
    return Device.fromJson(data);
  }

  /// Disconnect a device
  Future<bool> disconnectDevice(String serialNumber) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Mock implementation - find and update device status
    final index = _mockDevicesData.indexWhere(
      (device) => device['serialNumber'] == serialNumber,
    );

    if (index != -1) {
      _mockDevicesData[index]['status'] = 'Ended';
      _mockDevicesData[index]['isActive'] = false;
      _mockDevicesData[index]['endTime'] = DateTime.now().toString().split('.').first;
      return true;
    }

    return false;
  }

  /// Get device data/history
  Future<Map<String, dynamic>> getDeviceData(String serialNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'serialNumber': serialNumber,
      'dataPoints': 156,
      'lastUpdate': DateTime.now().toString().split('.').first,
      'averageGlucose': 142,
      'glucoseReadings': List.generate(
        10,
        (i) => {
          'timestamp': DateTime.now().subtract(Duration(hours: i)).toString().split('.').first,
          'value': 120 + (i * 5),
          'unit': 'mg/dL',
        },
      ),
    };
  }
}
