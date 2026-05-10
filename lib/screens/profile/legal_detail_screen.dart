import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LegalDetailScreen extends StatelessWidget {
  const LegalDetailScreen({
    super.key,
    required this.title,
    required this.bodyText,
  });

  final String title;
  final String bodyText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111111), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3E3E3)),
          ),
          child: Text(
            bodyText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4F5560),
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
}