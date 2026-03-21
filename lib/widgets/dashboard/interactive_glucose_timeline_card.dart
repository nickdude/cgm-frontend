import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/dashboard_data.dart';

class InteractiveGlucoseTimelineCard extends StatefulWidget {
  const InteractiveGlucoseTimelineCard({
    super.key,
    required this.points,
    required this.biomarkers,
    required this.onAddQuickAction,
  });

  final List<TimelinePoint> points;
  final List<TimelineBiomarker> biomarkers;
  final ValueChanged<int> onAddQuickAction;

  @override
  State<InteractiveGlucoseTimelineCard> createState() => _InteractiveGlucoseTimelineCardState();
}

class _InteractiveGlucoseTimelineCardState extends State<InteractiveGlucoseTimelineCard> {
  int _selectedIndex = 0;
  final GlobalKey _chartAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.points.isEmpty ? 0 : widget.points.length ~/ 2;
  }

  @override
  void didUpdateWidget(covariant InteractiveGlucoseTimelineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _selectedIndex = widget.points.isEmpty
          ? 0
          : _selectedIndex.clamp(0, widget.points.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    const chartHeight = 300.0;
    const tickSlotWidth = 110.0;
    final width = math.max(MediaQuery.sizeOf(context).width - 24, points.length * tickSlotWidth);
    final selectedPoint = points[_selectedIndex.clamp(0, points.length - 1)];
    final selectedLabel = _formatEpoch(selectedPoint.epochMs);
    final selectedRatio = points.length <= 1 ? 0.0 : _selectedIndex / (points.length - 1);
    final alignmentX = (selectedRatio * 2) - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: chartHeight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: width,
            child: Stack(
              children: [
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      selectedLabel,
                      style: const TextStyle(
                        color: Color(0xFF8C8F94),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 42,
                  left: 22,
                  right: 22,
                  bottom: 54,
                  child: CustomPaint(
                    painter: _InteractiveTimelinePainter(
                      points: points,
                      biomarkers: widget.biomarkers,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                ),
                Positioned(
                  key: _chartAreaKey,
                  top: 42,
                  left: 22,
                  right: 22,
                  bottom: 54,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final chartContext = _chartAreaKey.currentContext;
                      if (chartContext == null) return;
                      final box = chartContext.findRenderObject() as RenderBox;
                      final local = box.globalToLocal(details.globalPosition);
                      final localX = local.dx.clamp(0.0, box.size.width);
                      final ratio = box.size.width <= 0 ? 0.0 : localX / box.size.width;
                      final idx = (ratio * (points.length - 1)).round().clamp(0, points.length - 1);
                      setState(() => _selectedIndex = idx);
                    },
                  ),
                ),
                Positioned.fill(
                  top: 40,
                  child: Align(
                    alignment: Alignment(alignmentX, 0),
                    child: _ValuePill(
                      value: '${selectedPoint.glucoseValue} mg/dL',
                      onAddTap: () => widget.onAddQuickAction(selectedPoint.epochMs),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: points
                        .map(
                          (point) => SizedBox(
                            width: width / points.length,
                            child: Center(
                              child: Text(
                                point.label,
                                style: const TextStyle(
                                  color: Color(0xFF15181D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatEpoch(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final suffix = dt.hour >= 12 ? 'pm' : 'am';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')} $hour:$minute $suffix';
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.value, required this.onAddTap});

  final String value;
  final VoidCallback onAddTap;

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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF00A86B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 24, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveTimelinePainter extends CustomPainter {
  _InteractiveTimelinePainter({
    required this.points,
    required this.biomarkers,
    required this.selectedIndex,
  });

  final List<TimelinePoint> points;
  final List<TimelineBiomarker> biomarkers;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final left = 0.0;
    final right = size.width;
    final top = 8.0;
    final bottom = size.height - 8;

    final min = points.map((e) => e.glucoseValue).reduce(math.min).toDouble();
    final max = points.map((e) => e.glucoseValue).reduce(math.max).toDouble();
    final range = (max - min).abs() < 1 ? 1 : (max - min);

    Offset pointToOffset(int index) {
      final p = points[index];
      final x = left + ((right - left) * (index / (points.length - 1)));
      final normalizedY = (p.glucoseValue - min) / range;
      final y = bottom - normalizedY * (bottom - top);
      return Offset(x, y);
    }

    final baselinePaint = Paint()
      ..color = const Color(0xFFCFD3D8)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, bottom), Offset(size.width, bottom), baselinePaint);

    final selected = pointToOffset(selectedIndex.clamp(0, points.length - 1));
    final guidePaint = Paint()
      ..color = const Color(0xFFB8BEC6)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(selected.dx, top), Offset(selected.dx, bottom), guidePaint);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = pointToOffset(i);
      final p1 = pointToOffset(i + 1);
      final paint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE84A5F), Color(0xFF78B642)],
        ).createShader(Rect.fromPoints(p0, p1))
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p0, p1, paint);
    }

    for (final marker in biomarkers) {
      final nearestIndex = _nearestPointIndex(points, marker.epochMs);
      final center = pointToOffset(nearestIndex);
      _drawBiomarker(canvas, center, marker.icon);
    }

    canvas.drawCircle(selected, 12, Paint()..color = Colors.white);
    canvas.drawCircle(selected, 7, Paint()..color = const Color(0xFF617283));
  }

  int _nearestPointIndex(List<TimelinePoint> points, int epochMs) {
    var bestIndex = 0;
    var bestDelta = (points.first.epochMs - epochMs).abs();
    for (var i = 1; i < points.length; i++) {
      final delta = (points[i].epochMs - epochMs).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  void _drawBiomarker(Canvas canvas, Offset center, String icon) {
    final fill = Paint()..color = const Color(0xFFF1F3F5);
    final stroke = Paint()
      ..color = const Color(0xFF6D7680)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final markerY = (center.dy - 18).clamp(12.0, double.infinity);
    final markerCenter = Offset(center.dx, markerY);
    canvas.drawCircle(markerCenter, 11, fill);
    canvas.drawCircle(markerCenter, 11, stroke);

    final symbol = switch (icon) {
      'meal' => Icons.restaurant,
      'insulin' => Icons.vaccines,
      'medicine' => Icons.medication,
      'exercise' => Icons.directions_run,
      'finger-blood' => Icons.water_drop,
      _ => Icons.circle,
    };

    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(symbol.codePoint),
        style: TextStyle(
          fontSize: 12,
          fontFamily: symbol.fontFamily,
          package: symbol.fontPackage,
          color: const Color(0xFF59636E),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(markerCenter.dx - tp.width / 2, markerCenter.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _InteractiveTimelinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.biomarkers != biomarkers ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
