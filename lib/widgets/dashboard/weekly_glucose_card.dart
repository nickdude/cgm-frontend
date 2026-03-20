import 'package:flutter/material.dart';

class WeeklyGlucoseCard extends StatefulWidget {
  const WeeklyGlucoseCard({
    required this.weeklyData,
    this.onDaySelected,
    super.key,
  });

  final List<WeeklyGlucoseData> weeklyData;
  final ValueChanged<int>? onDaySelected;

  @override
  State<WeeklyGlucoseCard> createState() => _WeeklyGlucoseCardState();
}

class _WeeklyGlucoseCardState extends State<WeeklyGlucoseCard> {
  int _selectedDayIndex = 3; // Saturday by default

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(
              widget.weeklyData.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index < widget.weeklyData.length - 1 ? 24 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedDayIndex = index);
                    widget.onDaySelected?.call(index);
                  },
                  child: _GlucoseDay(
                    data: widget.weeklyData[index],
                    isSelected: _selectedDayIndex == index,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlucoseDay extends StatelessWidget {
  const _GlucoseDay({
    required this.data,
    required this.isSelected,
  });

  final WeeklyGlucoseData data;
  final bool isSelected;

  Color _getGlucoseColor() {
    if (data.value == null) return const Color(0xFFE8E8E8);
    if (data.value! <= 180) return const Color(0xFF4CAF50); // Green - controlled
    return const Color(0xFFFF6B6B); // Red - not controlled
  }

  @override
  Widget build(BuildContext context) {
    final glucoseColor = _getGlucoseColor();

    return Column(
      children: [
        // Day label with black background when selected
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.black : Colors.transparent,
          ),
          child: Center(
            child: Text(
              data.day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFFA8A8A8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Glucose circle with value inside
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: data.value == null
                ? Colors.transparent
                : glucoseColor.withOpacity(0.12),
          ),
          child: data.value != null
              ? Center(
                  child: Text(
                    '${data.value}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: glucoseColor,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class WeeklyGlucoseData {
  final String day;
  final int? value; // null means no data

  WeeklyGlucoseData({
    required this.day,
    this.value,
  });
}
