import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/device_setup/device_setup_widgets.dart';

class ImplantSensorStep2Screen extends StatelessWidget {
  const ImplantSensorStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageHeight = (screenWidth * 0.48).clamp(152.0, 188.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Implant the Sensor',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 36 / 2, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DeviceSetupImageCard(
                        assetPath: 'assets/images/device-setup/device-setup-3-1.png',
                        height: imageHeight,
                      ),
                      SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '3. Remove the safety pin by pulling it upwards.',
                          style: TextStyle(fontSize: 34 / 2, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 14),
                      DeviceSetupImageCard(
                        assetPath: 'assets/images/device-setup/device-setup-3-2.png',
                        height: imageHeight,
                      ),
                      SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '4. Place the applicator on the wearing site,\n   press it against the skin, and push the\n   application button.',
                          style: TextStyle(fontSize: 34 / 2, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DeviceSetupPrimaryButton(
                label: 'Next',
                onTap: () => context.push('/device/implant/step-3'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
