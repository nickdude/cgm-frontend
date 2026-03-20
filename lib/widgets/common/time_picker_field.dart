import 'package:flutter/material.dart';

class TimePickerField extends StatefulWidget {
  const TimePickerField({
    required this.label,
    this.initialTime,
    this.onChanged,
    super.key,
  });

  final String label;
  final String? initialTime;
  final ValueChanged<String>? onChanged;

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  late String _displayTime;

  @override
  void initState() {
    super.initState();
    _displayTime = widget.initialTime ?? '08-03 17:28';
  }

  Future<void> _selectTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (!mounted) return;
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (timePicked != null) {
        final formatted =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')} ${timePicked.hour.toString().padLeft(2, '0')}:${timePicked.minute.toString().padLeft(2, '0')}';
        setState(() => _displayTime = formatted);
        widget.onChanged?.call(formatted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFFC8C8C8),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: const Color(0xFFE8E8E8),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _displayTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA8A8A8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
