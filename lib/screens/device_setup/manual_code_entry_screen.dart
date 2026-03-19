import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/device_setup/device_setup_widgets.dart';

class ManualCodeEntryScreen extends StatefulWidget {
  const ManualCodeEntryScreen({super.key});

  @override
  State<ManualCodeEntryScreen> createState() => _ManualCodeEntryScreenState();
}

class _ManualCodeEntryScreenState extends State<ManualCodeEntryScreen> {
  final _codeController = TextEditingController();

  bool get _isValid => _codeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _codeController.removeListener(_onChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onComplete() {
    if (!_isValid) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device code captured successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                style: TextStyle(
                                  fontSize: 36 / 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const DeviceSetupImageCard(
                          assetPath: 'assets/images/device-setup/device-setup-4-1.png',
                          height: 150,
                        ),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'The connection code is located below the QR\ncode at the bottom of the needle aid.',
                            style: TextStyle(
                              fontSize: 30 / 2,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111111),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 60,
                          child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              hintText: 'Enter the code',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFD9DADC)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFD9DADC)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                DeviceSetupPrimaryButton(
                  label: 'Complete',
                  onTap: _onComplete,
                  isEnabled: _isValid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
