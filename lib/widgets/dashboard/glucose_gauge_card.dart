import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlucoseGaugeCard extends StatefulWidget {
  final int glucoseValue;
  final String unit;
  final bool isControlled;
  final VoidCallback? onToggle;

  const GlucoseGaugeCard({
    Key? key,
    required this.glucoseValue,
    this.unit = 'mg/dL',
    this.isControlled = true,
    this.onToggle,
  }) : super(key: key);

  @override
  State<GlucoseGaugeCard> createState() => _GlucoseGaugeCardState();
}

class _GlucoseGaugeCardState extends State<GlucoseGaugeCard> {
  late bool _toggleState;

  @override
  void initState() {
    super.initState();
    _toggleState = widget.isControlled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle background ring (dashed)
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _DashedCirclePainter(
                    color: const Color(0xFFF0F0F0),
                    strokeWidth: 6,
                  ),
                ),
                // Arc progress
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _CircleArcPainter(
                    progress: (widget.glucoseValue / 300).clamp(0.0, 1.0),
                    color: widget.isControlled
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF6B6B),
                    strokeWidth: 6,
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Glucose',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA8A8A8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.glucoseValue}',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.arrow_upward,
                            size: 18,
                            color: widget.isControlled
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.unit,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Toggle switch
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _toggleState = !_toggleState;
                  });
                  widget.onToggle?.call();
                },
                child: Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _toggleState
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE8E8E8),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: _toggleState ? 22 : 2,
                        top: 2,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const startAngle = -math.pi / 2;
    const fullAngle = 2 * math.pi;

    // Draw complete dashed circle
    final dashLength = 8.0;
    final gapLength = 6.0;

    var currentAngle = startAngle;

    while (currentAngle < startAngle + fullAngle) {
      final nextAngle = currentAngle + (dashLength / radius);
      final actualEndAngle = nextAngle > startAngle + fullAngle ? startAngle + fullAngle : nextAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        actualEndAngle - currentAngle,
        false,
        paint,
      );

      currentAngle = actualEndAngle + (gapLength / radius);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _CircleArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircleArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Draw dashed arc
    final dashLength = 8.0;
    final gapLength = 6.0;

    var currentAngle = startAngle;
    final endAngle = startAngle + sweepAngle;

    while (currentAngle < endAngle) {
      final nextAngle = currentAngle + (dashLength / radius);
      final actualEndAngle = nextAngle > endAngle ? endAngle : nextAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        actualEndAngle - currentAngle,
        false,
        paint,
      );

      currentAngle = actualEndAngle + (gapLength / radius);
    }
  }

  @override
  bool shouldRepaint(_CircleArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
