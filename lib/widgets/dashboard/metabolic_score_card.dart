import 'package:flutter/material.dart';

class MetabolicScoreCard extends StatelessWidget {
  final int score;
  final String? timestamp;
  final bool isImproved;
  final String? label;

  const MetabolicScoreCard({
    Key? key,
    required this.score,
    this.timestamp,
    this.isImproved = true,
    this.label = 'Metabolic Score',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score with arrow
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50),
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  isImproved ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                  color: isImproved
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            label ?? 'Metabolic Score',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 14),
          // Horizontal divider
          Container(
            height: 1,
            color: const Color(0xFFE8E8E8),
          ),
          const SizedBox(height: 12),
          // Timestamp and indicator
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timestamp ?? '74 mg/dL · 5:22 pm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA8A8A8),
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
