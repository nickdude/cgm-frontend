import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class GlucoseTimelineCard extends StatelessWidget {
  const GlucoseTimelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: 300,
            child: Stack(
              children: [
                const Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '10:25 am',
                      style: TextStyle(
                        color: Color(0xFF8C8F94),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 42,
                  left: 44,
                  right: 44,
                  bottom: 54,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDEF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDEF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  top: 52,
                  bottom: 56,
                  child: CustomPaint(
                    painter: _TimelinePainter(),
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ValuePill(),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '6 am',
                        style: TextStyle(
                          color: Color(0xFF15181D),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '9 am',
                        style: TextStyle(
                          color: Color(0xFF15181D),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '12 pm',
                        style: TextStyle(
                          color: Color(0xFF15181D),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '3 pm',
                        style: TextStyle(
                          color: Color(0xFF15181D),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3237),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '176 mg/dL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF00A86B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgLine = Paint()
      ..color = const Color(0xFFC8CCD2)
      ..strokeWidth = 1.6;

    final dash = Paint()
      ..color = const Color(0xFFCFD3D8)
      ..strokeWidth = 1;

    final centerX = size.width * 0.5;
    canvas.drawLine(Offset(centerX, 10), Offset(centerX, size.height - 8), bgLine);

    // Glucose baseline
    final baseY = size.height * 0.70;
    _drawDashedLine(
      canvas,
      Offset(0, baseY),
      Offset(size.width, baseY),
      dash,
      dashLength: 6,
      gapLength: 5,
    );

    _drawDashedLine(
      canvas,
      Offset(0, size.height - 8),
      Offset(size.width, size.height - 8),
      dash,
      dashLength: 6,
      gapLength: 5,
    );

    final points = <Offset>[
      Offset(0, size.height * 0.34),
      Offset(size.width * 0.02, size.height * 0.36),
      Offset(size.width * 0.04, size.height * 0.24),
      Offset(size.width * 0.06, size.height * 0.16),
      Offset(size.width * 0.08, size.height * 0.30),
      Offset(size.width * 0.10, size.height * 0.48),
      Offset(size.width * 0.13, size.height * 0.21),
      Offset(size.width * 0.16, size.height * 0.38),
      Offset(size.width * 0.20, size.height * 0.58),
      Offset(size.width * 0.24, size.height * 0.48),
      Offset(size.width * 0.30, size.height * 0.56),
      Offset(size.width * 0.36, size.height * 0.50),
      Offset(size.width * 0.42, size.height * 0.58),
      Offset(size.width * 0.48, size.height * 0.52),
      Offset(size.width * 0.54, size.height * 0.76),
      Offset(size.width * 0.60, size.height * 0.82),
      Offset(size.width * 0.66, size.height * 0.60),
      Offset(size.width * 0.72, size.height * 0.50),
      Offset(size.width * 0.78, size.height * 0.54),
      Offset(size.width * 0.82, size.height * 0.52),
      Offset(size.width * 0.86, size.height * 0.38),
      Offset(size.width * 0.88, size.height * 0.20),
      Offset(size.width * 0.90, size.height * 0.36),
      Offset(size.width * 0.92, size.height * 0.28),
      Offset(size.width * 0.95, size.height * 0.52),
      Offset(size.width * 1.00, size.height * 0.60),
    ];

    // Single line with smooth gradient by glucose level (high -> red/orange, normal -> green)
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final c0 = _lineColorForY(p0.dy, size.height);
      final c1 = _lineColorForY(p1.dy, size.height);

      final paint = Paint()
        ..shader = ui.Gradient.linear(
          p0,
          p1,
          [c0, c1],
        )
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawLine(p0, p1, paint);
    }

    // + annotations
    _drawText(canvas, '+31', Offset(size.width * 0.08, size.height * 0.03), const Color(0xFFFF5A3B));
    _drawDownTriangle(canvas, Offset(size.width * 0.14, size.height * 0.12), const Color(0xFFFF5A3B));
    _drawText(canvas, '+35', Offset(size.width * 0.79, size.height * 0.08), const Color(0xFFFF5A3B));
    _drawDownTriangle(canvas, Offset(size.width * 0.85, size.height * 0.17), const Color(0xFFFF5A3B));

    // Event markers
    _drawMarker(canvas, Offset(size.width * 0.09, size.height * 0.48), Icons.local_bar_outlined, const Color(0xFF59636E));
    _drawMarker(canvas, Offset(size.width * 0.48, size.height * 0.60), Icons.wb_sunny_outlined, const Color(0xFF59636E));
    _drawMarker(canvas, Offset(size.width * 0.88, size.height * 0.58), Icons.restaurant_outlined, const Color(0xFF59636E));

    // Center selector
    final centerPoint = Offset(centerX, size.height * 0.70);
    canvas.drawCircle(centerPoint, 13, Paint()..color = Colors.white);
    canvas.drawCircle(centerPoint, 9, Paint()..color = const Color(0xFF617283));
  }

  Color _lineColorForY(double y, double chartHeight) {
    final top = chartHeight * 0.16;
    final bottom = chartHeight * 0.84;
    final t = ((y - top) / (bottom - top)).clamp(0.0, 1.0);

    const red = Color(0xFFE84A5F);
    const orange = Color(0xFFF08C2B);
    const yellow = Color(0xFFD4BC2F);
    const green = Color(0xFF78B642);

    if (t < 0.35) {
      return Color.lerp(red, orange, t / 0.35)!;
    }
    if (t < 0.65) {
      return Color.lerp(orange, yellow, (t - 0.35) / 0.30)!;
    }
    return Color.lerp(yellow, green, (t - 0.65) / 0.35)!;
  }

  void _drawDownTriangle(Canvas canvas, Offset center, Color color) {
    final path = Path()
      ..moveTo(center.dx - 7, center.dy - 3)
      ..lineTo(center.dx + 7, center.dy - 3)
      ..lineTo(center.dx, center.dy + 8)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawMarker(Canvas canvas, Offset center, IconData icon, Color iconColor) {
    final fill = Paint()..color = const Color(0xFFF1F3F5);
    final stroke = Paint()
      ..color = const Color(0xFF6D7680)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 13, fill);
    canvas.drawCircle(center, 13, stroke);

    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 14,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashLength = 6,
    double gapLength = 4,
  }) {
    final totalLength = (end - start).distance;
    final direction = (end - start) / totalLength;
    double current = 0;

    while (current < totalLength) {
      final dashStart = start + direction * current;
      final dashEnd = start + direction * math.min(current + dashLength, totalLength);
      canvas.drawLine(dashStart, dashEnd, paint);
      current += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) => false;
}
