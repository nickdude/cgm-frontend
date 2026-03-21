import 'package:flutter/material.dart';

class WeeklyGlucoseCard extends StatefulWidget {
  const WeeklyGlucoseCard({
    required this.weeklyData,
    this.initialSelectedIndex = 0,
    this.onDaySelected,
    super.key,
  });

  final List<WeeklyGlucoseData> weeklyData;
  final int initialSelectedIndex;
  final ValueChanged<int>? onDaySelected;

  @override
  State<WeeklyGlucoseCard> createState() => _WeeklyGlucoseCardState();
}

class _WeeklyGlucoseCardState extends State<WeeklyGlucoseCard> {
  late int _selectedDayIndex;
  static const double _slotWidth = 64;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.weeklyData.isEmpty
        ? 0
        : widget.initialSelectedIndex.clamp(0, widget.weeklyData.length - 1);
  }

  @override
  void didUpdateWidget(covariant WeeklyGlucoseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedIndex != widget.initialSelectedIndex ||
        oldWidget.weeklyData.length != widget.weeklyData.length) {
      _selectedDayIndex = widget.weeklyData.isEmpty
          ? 0
          : widget.initialSelectedIndex.clamp(0, widget.weeklyData.length - 1);
    }
  }

  _ValueStyle _styleForValue(int value) {
    if (value < 80) {
      return const _ValueStyle(
        text: Color(0xFFE0662A),
        background: Color(0xFFF3E5DD),
      );
    }

    return const _ValueStyle(
      text: Color(0xFF45A352),
      background: Color(0xFFDCEBDE),
    );
  }

  List<_ValueSegment> _buildSegments() {
    final data = widget.weeklyData;
    final segments = <_ValueSegment>[];

    int i = 0;
    while (i < data.length) {
      final current = data[i];
      if (current.value == null) {
        segments.add(
          _ValueSegment(
            startIndex: i,
            endIndex: i,
            values: const [],
            style: null,
          ),
        );
        i += 1;
        continue;
      }

      final style = _styleForValue(current.value!);
      int j = i;
      final values = <int>[];

      while (j < data.length && data[j].value != null && _styleForValue(data[j].value!) == style) {
        values.add(data[j].value!);
        j += 1;
      }

      segments.add(
        _ValueSegment(
          startIndex: i,
          endIndex: j - 1,
          values: values,
          style: style,
        ),
      );

      i = j;
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final segments = _buildSegments();

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Row(
                children: List.generate(widget.weeklyData.length, (index) {
                  final isSelected = _selectedDayIndex == index;
                  return SizedBox(
                    width: _slotWidth,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDayIndex = index);
                        widget.onDaySelected?.call(index);
                      },
                      child: Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFF0F1216) : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              widget.weeklyData[index].day,
                              style: TextStyle(
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFFA2A2A2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Row(
                children: segments.map((segment) {
                  final count = segment.endIndex - segment.startIndex + 1;
                  final width = _slotWidth * count;

                  if (segment.values.isEmpty) {
                    return SizedBox(
                      width: width,
                      child: const Center(
                        child: _EmptyBadge(),
                      ),
                    );
                  }

                  final style = segment.style!;
                  if (segment.values.length == 1) {
                    return SizedBox(
                      width: width,
                      child: Center(
                        child: _SingleValueBadge(
                          value: segment.values.first,
                          style: style,
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    width: width,
                    child: Center(
                      child: _GroupedValueBadge(values: segment.values, style: style),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBadge extends StatelessWidget {
  const _EmptyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCDCED0), width: 2.3),
      ),
    );
  }
}

class _SingleValueBadge extends StatelessWidget {
  const _SingleValueBadge({required this.value, required this.style});

  final int value;
  final _ValueStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.background,
      ),
      child: Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 34 / 2,
            fontWeight: FontWeight.w600,
            color: style.text,
          ),
        ),
      ),
    );
  }
}

class _GroupedValueBadge extends StatelessWidget {
  const _GroupedValueBadge({required this.values, required this.style});

  final List<int> values;
  final _ValueStyle style;

  @override
  Widget build(BuildContext context) {
    final width = values.length * 56 + (values.length - 1) * 6;

    return Container(
      width: width.toDouble(),
      height: 56,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: values
            .map(
              (value) => Text(
                '$value',
                style: TextStyle(
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w600,
                  color: style.text,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ValueStyle {
  const _ValueStyle({required this.text, required this.background});

  final Color text;
  final Color background;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ValueStyle && other.text == text && other.background == background;
  }

  @override
  int get hashCode => Object.hash(text, background);
}

class _ValueSegment {
  const _ValueSegment({
    required this.startIndex,
    required this.endIndex,
    required this.values,
    required this.style,
  });

  final int startIndex;
  final int endIndex;
  final List<int> values;
  final _ValueStyle? style;
}

class WeeklyGlucoseData {
  final String day;
  final int? value; // null means no data

  WeeklyGlucoseData({
    required this.day,
    this.value,
  });
}
