import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  static const double _gaugeSize = 286;
  static const double _ringStrokeWidth = 4.2;
  static const double _dashLength = 8.4;
  static const double _dashGap = 10.8;
  static const double _startAngle = -math.pi / 2 + 0.08;

  double get _progress => (widget.glucoseValue / 250).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _toggleState = widget.isControlled;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            width: _gaugeSize,
            height: _gaugeSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(_gaugeSize, _gaugeSize),
                  painter: _DashedCirclePainter(
                    color: const Color(0xFFE3E4E6),
                    strokeWidth: _ringStrokeWidth,
                    dashLength: _dashLength,
                    gapLength: _dashGap,
                    startAngle: _startAngle,
                  ),
                ),
                CustomPaint(
                  size: const Size(_gaugeSize, _gaugeSize),
                  painter: _CircleArcPainter(
                    progress: _progress,
                    color: widget.isControlled ? const Color(0xFF4BAE59) : const Color(0xFFE35D5D),
                    strokeWidth: _ringStrokeWidth,
                    dashLength: _dashLength,
                    gapLength: _dashGap,
                    startAngle: _startAngle,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Glucose',
                      style: TextStyle(
                        fontSize: 42 / 2,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4146),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.glucoseValue}',
                          style: const TextStyle(
                            fontSize: 130 / 2,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: SvgPicture.asset(
                            'assets/icons/Union.svg',
                            width: 52 / 2,
                            height: 52 / 2,
                            colorFilter: ColorFilter.mode(
                              widget.isControlled ? const Color(0xFF4BAE59) : const Color(0xFFE35D5D),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.unit,
                      style: const TextStyle(
                        fontSize: 68 / 2,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF404247),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _toggleState = !_toggleState;
                        });
                        widget.onToggle?.call();
                      },
                      child: Container(
                        width: 44,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _toggleState ? const Color(0xFF020202) : const Color(0xFFB7B9BC),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Align(
                          alignment: _toggleState ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double startAngle;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.startAngle,
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

    const fullAngle = 2 * math.pi;

    // Draw complete dashed circle
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
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.startAngle != startAngle;
  }
}

class _CircleArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double startAngle;

  _CircleArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.startAngle,
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

    final sweepAngle = 2 * math.pi * progress;

    // Draw dashed arc
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
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.startAngle != startAngle;
  }
}
