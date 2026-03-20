import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

enum ProfileContactMode {
  phoneLoginNeedsEmail,
  emailLoginNeedsPhone,
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    required this.contactMode,
    this.prefilledPhone,
    this.prefilledEmail,
    super.key,
  });

  final ProfileContactMode contactMode;
  final String? prefilledPhone;
  final String? prefilledEmail;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _photoBytes;
  String? _photoPath;
  String? _existingPhotoUrl;
  bool _didPrefillFromProfile = false;

  bool get _isPhoneFlow =>
      widget.contactMode == ProfileContactMode.phoneLoginNeedsEmail;

  String _normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  void _prefillFromExistingProfile() {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return;
    }

    if (user.fullName.trim().isNotEmpty) {
      _nameController.text = user.fullName.trim();
    }

    if (_isPhoneFlow) {
      if (user.email.trim().isNotEmpty) {
        _emailController.text = user.email.trim();
      }
    } else {
      final phone = user.phone != null ? _normalizePhone(user.phone!) : '';
      if (phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    }

    if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty) {
      _existingPhotoUrl = user.photoUrl!.trim();
    }
  }

  bool _isValidEmail(String email) {
    final value = email.trim();
    if (value.isEmpty || value.contains(' ')) {
      return false;
    }

    final atIndex = value.indexOf('@');
    if (atIndex <= 0 || atIndex != value.lastIndexOf('@')) {
      return false;
    }

    final domain = value.substring(atIndex + 1);
    return domain.contains('.') && !domain.startsWith('.') && !domain.endsWith('.');
  }

  bool get _isFormValid {
    final nameValid = _nameController.text.trim().isNotEmpty;

    if (_isPhoneFlow) {
      final email = _emailController.text.trim();
      final emailValid = _isValidEmail(email);
      return nameValid && emailValid;
    }

    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return nameValid && phoneDigits.length >= 10;
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _photoBytes = bytes;
        _photoPath = file.path;
        _existingPhotoUrl = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to pick image. Please check permissions.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick image right now. Try again.')),
      );
    }
  }

  Future<void> _onContinue() async {
    if (!_isFormValid) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final userId = authProvider.user?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    final payload = {
      'fullName': _nameController.text.trim(),
      'email': _isPhoneFlow ? _emailController.text.trim() : widget.prefilledEmail,
      'phone': _isPhoneFlow
          ? widget.prefilledPhone
          : _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    };

    if (_photoPath != null && _photoPath!.isNotEmpty) {
      final photoUploaded = await profileProvider.uploadPhoto(userId, _photoPath!);
      if (!mounted) {
        return;
      }

      if (!photoUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(profileProvider.error ?? 'Unable to upload photo')),
        );
        return;
      }
    }

    final success = await profileProvider.updateProfile(userId, payload);
    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profileProvider.error ?? 'Unable to save profile')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile details saved successfully.')),
    );

    context.push('/onboarding');
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.prefilledEmail ?? '';
    _phoneController.text = widget.prefilledPhone ?? '';

    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrefillFromProfile) {
      return;
    }

    _prefillFromExistingProfile();
    _didPrefillFromProfile = true;
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compactHeight = screenHeight < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text(
                      'Perfect! Now let\'s set up\nyour profile',
                      style: TextStyle(
                        fontSize: 56 / 2,
                        height: 1.22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Complete profile to enhance your experience',
                      style: TextStyle(
                        fontSize: 19 / 2 * 2,
                        color: Colors.black.withValues(alpha: 0.42),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 38),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            width: 122,
                            height: 122,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF6F6F7),
                              border: Border.all(color: const Color(0xFFE4E4E6)),
                              image: _photoBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_photoBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : (_existingPhotoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(_existingPhotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: (_photoBytes == null && _existingPhotoUrl == null)
                                ? const Icon(
                                    Icons.photo_size_select_actual_outlined,
                                    color: Color(0xFF737373),
                                    size: 36,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: SizedBox(
                            height: 72,
                            child: OutlinedButton.icon(
                              onPressed: _pickPhoto,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFD9DADC)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.cloud_upload_outlined,
                                color: Color(0xFF111111),
                                size: 30 / 2 * 2,
                              ),
                              label: const Text(
                                'Upload new photo',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 20 / 2 * 2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 56),
                    const Text(
                      'Full name',
                      style: TextStyle(
                        fontSize: 20 / 2 * 2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileInput(
                      controller: _nameController,
                      hint: 'Enter your name',
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isPhoneFlow ? 'Email address' : 'Mobile Number',
                      style: const TextStyle(
                        fontSize: 20 / 2 * 2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isPhoneFlow)
                      _ProfileInput(
                        controller: _emailController,
                        hint: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                      )
                    else
                      Row(
                        children: [
                          Container(
                            width: 86,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFD9DADC)),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🇮🇳', style: TextStyle(fontSize: 22)),
                                SizedBox(width: 6),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 18 / 2 * 2,
                                    color: Color(0xFF1F2933),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileInput(
                              controller: _phoneController,
                              hint: 'Enter mobile number',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compactHeight ? 36 : 96),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed:
                        (_isFormValid && !profileProvider.isLoading) ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFBFC0C2),
                      backgroundColor: const Color(0xFF7B7C87),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: profileProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 22 / 2 * 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 24),
                              Icon(Icons.arrow_forward, size: 30 / 2 * 2),
                            ],
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

class _ProfileInput extends StatelessWidget {
  const _ProfileInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF6B6F75),
            fontSize: 20 / 2 * 2,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9DADC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9DADC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1F2933), width: 1.3),
          ),
        ),
      ),
    );
  }
}
