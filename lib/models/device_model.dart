class Device {
  final String serialNumber;
  final String activationTime;
  final String usageTime;
  final String endTime;
  final String status; // "In Use" or "Ended"
  final bool isActive;

  Device({
    required this.serialNumber,
    required this.activationTime,
    required this.usageTime,
    required this.endTime,
    required this.status,
    required this.isActive,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      serialNumber: json['serialNumber'] as String? ?? '',
      activationTime: json['activationTime'] as String? ?? '',
      usageTime: json['usageTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? 'Ended',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'activationTime': activationTime,
      'usageTime': usageTime,
      'endTime': endTime,
      'status': status,
      'isActive': isActive,
    };
  }
}
