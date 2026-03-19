import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/device_setup/device_setup_widgets.dart';

class DeviceSetupHomeScreen extends StatelessWidget {
  const DeviceSetupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = (screenHeight * 0.44).clamp(240.0, 395.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'CGMS365',
                            style: TextStyle(
                              fontSize: 38 / 2,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9EAEC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DeviceSetupImageCard(
                        assetPath: 'assets/images/device-setup/device-setup-1-1.png',
                        height: imageHeight,
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Please apply a new sensor first.',
                          style: TextStyle(
                            fontSize: 34 / 2,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      DeviceSetupPrimaryButton(
                        label: 'Click to Start',
                        onTap: () => context.push('/device/implant/step-1'),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'B',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 30 / 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
