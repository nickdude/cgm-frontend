import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../models/device_model.dart';

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({super.key});

  @override
  State<DevicesListScreen> createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.arrow_back,
            color: Color(0xFF111111),
            size: 24,
          ),
        ),
        centerTitle: false,
        title: const Text(
          'Device',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, _) {
          if (deviceProvider.isLoading && deviceProvider.devices.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (deviceProvider.error != null && deviceProvider.devices.isEmpty) {
            return Center(
              child: Text(
                deviceProvider.error!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C717B),
                ),
              ),
            );
          }

          if (deviceProvider.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices,
                    size: 64,
                    color: const Color(0xFFD9DCE1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No devices found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your CGM devices will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C717B),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: List.generate(
                deviceProvider.devices.length,
                (index) => _DeviceCard(
                  device: deviceProvider.devices[index],
                  onDataList: () => _showDeviceData(context, deviceProvider, deviceProvider.devices[index]),
                  onDisconnect: () => _handleDisconnect(context, deviceProvider, deviceProvider.devices[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeviceData(BuildContext context, DeviceProvider provider, Device device) async {
    await provider.loadDeviceData(device.serialNumber);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Consumer<DeviceProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = provider.deviceData;
                if (data == null) {
                  return const Center(child: Text('No data available'));
                }

                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9DCE1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Device Data - ${data['serialNumber']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DataInfoCard(
                        label: 'Data Points',
                        value: '${data['dataPoints']}',
                      ),
                      const SizedBox(height: 12),
                      _DataInfoCard(
                        label: 'Last Update',
                        value: data['lastUpdate'] ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _DataInfoCard(
                        label: 'Average Glucose',
                        value: '${data['averageGlucose']} mg/dL',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Recent Readings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        (data['glucoseReadings'] as List).length,
                        (index) {
                          final reading = data['glucoseReadings'][index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE3E3E3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reading['timestamp'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6C717B),
                                    ),
                                  ),
                                  Text(
                                    '${reading['value']} ${reading['unit']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleDisconnect(BuildContext context, DeviceProvider provider, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Device?'),
        content: Text('Are you sure you want to disconnect ${device.serialNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.disconnectDevice(device.serialNumber);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Device disconnected successfully' : 'Failed to disconnect device',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Disconnect',
              style: TextStyle(color: Color(0xFFE63946)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onDataList;
  final VoidCallback onDisconnect;

  const _DeviceCard({
    required this.device,
    required this.onDataList,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isActive ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E);
    final statusBg = device.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serial number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                device.serialNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  device.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Device details
          _DetailRow(label: 'Activation Time: ', value: device.activationTime),
          const SizedBox(height: 8),
          _DetailRow(label: 'Usage Time: ', value: device.usageTime),
          const SizedBox(height: 8),
          _DetailRow(label: 'End time: ', value: device.endTime),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onDataList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Data List',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: device.isActive ? onDisconnect : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: device.isActive ? const Color(0xFFE63946) : const Color(0xFFE3E3E3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Disconnect',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: device.isActive ? Colors.white : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C717B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF111111),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DataInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _DataInfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C717B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
