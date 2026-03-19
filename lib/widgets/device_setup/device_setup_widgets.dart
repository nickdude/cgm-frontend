import 'package:flutter/material.dart';

class DeviceSetupPrimaryButton extends StatelessWidget {
  const DeviceSetupPrimaryButton({
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFF7B7C87),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class DeviceSetupImageCard extends StatelessWidget {
  const DeviceSetupImageCard({
    required this.assetPath,
    this.height = 190,
    this.highlight = false,
    super.key,
  });

  final String assetPath;
  final double height;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(color: const Color(0xFF2196F3), width: 4)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFE5E7EB),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 36,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 8),
                Text(
                  assetPath,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceSetupOptionCard extends StatelessWidget {
  const DeviceSetupOptionCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.black : const Color(0xFFD9DADC),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : const Color(0xFFF1F1F2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSelected ? Colors.black : const Color(0xFFE1E2E4),
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
