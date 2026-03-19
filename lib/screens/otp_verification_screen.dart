import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    super.key,
  });

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  final List<String> _digits = List.filled(_otpLength, '');

  int get _filledCount => _digits.where((digit) => digit.isNotEmpty).length;
  bool get _isOtpComplete => _filledCount == _otpLength;

  String get _otp => _digits.join();

  void _onNumberTap(String value) {
    if (_filledCount >= _otpLength) {
      return;
    }

    final nextIndex = _digits.indexWhere((digit) => digit.isEmpty);
    if (nextIndex == -1) {
      return;
    }

    setState(() {
      _digits[nextIndex] = value;
    });
  }

  void _onBackspaceTap() {
    if (_filledCount == 0) {
      return;
    }

    final lastFilledIndex = _digits.lastIndexWhere((digit) => digit.isNotEmpty);
    if (lastFilledIndex == -1) {
      return;
    }

    setState(() {
      _digits[lastFilledIndex] = '';
    });
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTP(widget.phoneNumber, _otp);

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'OTP verification failed'),
        ),
      );
      return;
    }

    final phoneDigits = widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    context.push('/profile/setup/phone-login?phone=$phoneDigits');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1F2933),
                          size: 30,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 66),
                      const Text(
                        '6- digit code',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2933),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Code sent ${widget.phoneNumber} unless you already\nhave an account',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black.withValues(alpha: 0.42),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 46),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < _otpLength; i++) ...[
                              _OtpCell(value: _digits[i]),
                              if (i == 2)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD0D1D4),
                                    ),
                                  ),
                                )
                              else if (i < _otpLength - 1)
                                const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          const Text(
                            'No code received? ',
                            style: TextStyle(
                              fontSize: 19,
                              color: Color(0xFF4A4A4A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: authProvider.isLoading
                                ? null
                                : () async {
                                    final provider = context.read<AuthProvider>();
                                    final messenger = ScaffoldMessenger.of(context);
                                    final success = await provider.signUpWithPhone(
                                      widget.phoneNumber,
                                    );
                                    if (!mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'OTP resent (use 123456)'
                                              : 'Unable to resend OTP',
                                        ),
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: Color(0xFF005B58),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF005B58),
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 126),
                      SizedBox(
                        width: double.infinity,
                        height: 72,
                        child: ElevatedButton(
                          onPressed: (!authProvider.isLoading && _isOtpComplete)
                              ? _verifyOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: const Color(0xFF7B7C87),
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _OtpKeyboard(
              onNumberTap: _onNumberTap,
              onBackspaceTap: _onBackspaceTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF9F9FA),
        border: Border.all(color: const Color(0xFFE7E7E8)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF1F2933),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OtpKeyboard extends StatelessWidget {
  const _OtpKeyboard({
    required this.onNumberTap,
    required this.onBackspaceTap,
  });

  final ValueChanged<String> onNumberTap;
  final VoidCallback onBackspaceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD1D3D9),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KeyboardRow(
            children: const [
              _NumberKey(number: '1', letters: ''),
              _NumberKey(number: '2', letters: 'ABC'),
              _NumberKey(number: '3', letters: 'DEF'),
            ],
            onNumberTap: onNumberTap,
          ),
          const SizedBox(height: 8),
          _KeyboardRow(
            children: const [
              _NumberKey(number: '4', letters: 'GHI'),
              _NumberKey(number: '5', letters: 'JKL'),
              _NumberKey(number: '6', letters: 'MNO'),
            ],
            onNumberTap: onNumberTap,
          ),
          const SizedBox(height: 8),
          _KeyboardRow(
            children: const [
              _NumberKey(number: '7', letters: 'PQRS'),
              _NumberKey(number: '8', letters: 'TUV'),
              _NumberKey(number: '9', letters: 'WXYZ'),
            ],
            onNumberTap: onNumberTap,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 2,
                child: _KeyboardActionKey(
                  onTap: () => onNumberTap('0'),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KeyboardActionKey(
                  onTap: onBackspaceTap,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: Color(0xFF1E1E1E),
                    size: 28,
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

class _KeyboardRow extends StatelessWidget {
  const _KeyboardRow({
    required this.children,
    required this.onNumberTap,
  });

  final List<_NumberKey> children;
  final ValueChanged<String> onNumberTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(
            child: _KeyboardActionKey(
              onTap: () => onNumberTap(children[i].number),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    children[i].number,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (children[i].letters.isNotEmpty)
                    Text(
                      children[i].letters,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (i < children.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _KeyboardActionKey extends StatelessWidget {
  const _KeyboardActionKey({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Material(
        color: const Color(0xFFF6F6F7),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _NumberKey {
  const _NumberKey({required this.number, required this.letters});

  final String number;
  final String letters;
}
