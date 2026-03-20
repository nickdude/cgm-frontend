import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActionHeader extends StatelessWidget {
  const QuickActionHeader({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F3F4),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34 / 2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                left: 8,
                child: IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }

                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 22,
                    color: Color(0xFF111111),
                  ),
                  splashRadius: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
