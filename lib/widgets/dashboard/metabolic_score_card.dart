import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

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

  ({String reading, String time}) _parts() {
    final raw = (timestamp ?? '74 mg/dL · 5:22 pm').trim();
    final normalized = raw.replaceAll('•', '·');
    final split = normalized.split('·');
    if (split.length < 2) {
      return (reading: raw, time: '');
    }
    return (reading: split.first.trim(), time: split.sublist(1).join('·').trim());
  }

  @override
  Widget build(BuildContext context) {
    final parts = _parts();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 18, 20, isCompact ? 18 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 38 / 1.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0C9A5B),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4.5),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Transform.rotate(
                      angle: isImproved ? -math.pi / 4 : math.pi * 3 / 4,
                      child: SvgPicture.asset(
                        'assets/icons/Union.svg',
                        width: 17,
                        height: 17,
                        colorFilter: ColorFilter.mode(
                          isImproved ? const Color(0xFF0C9A5B) : const Color(0xFFE35D5D),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label ?? 'Metabolic Score',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48 / 2,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF696C74),
                ),
              ),
              const SizedBox(height: 22),
              if (isCompact)
                Column(
                  children: [
                    _IndicatorLine(width: (constraints.maxWidth * 0.44).clamp(122.0, 150.0)),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: parts.reading,
                              style: const TextStyle(
                                fontSize: 68 / 2,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000000),
                                height: 1,
                              ),
                            ),
                            const TextSpan(
                              text: ' · ',
                              style: TextStyle(
                                fontSize: 68 / 2,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7A7D85),
                                height: 1,
                              ),
                            ),
                            TextSpan(
                              text: parts.time,
                              style: const TextStyle(
                                fontSize: 68 / 2,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6F7178),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const _IndicatorLine(width: 150),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: parts.reading,
                                style: const TextStyle(
                                  fontSize: 68 / 2,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                  height: 1,
                                ),
                              ),
                              const TextSpan(
                                text: ' · ',
                                style: TextStyle(
                                  fontSize: 68 / 2,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7A7D85),
                                  height: 1,
                                ),
                              ),
                              TextSpan(
                                text: parts.time,
                                style: const TextStyle(
                                  fontSize: 68 / 2,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6F7178),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _IndicatorLine extends StatelessWidget {
  const _IndicatorLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            child: Container(
              width: width,
              height: 2.2,
              decoration: BoxDecoration(
                color: const Color(0xFFED3A2D),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFF0C9A5B), width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0C9A5B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
