import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  const DropdownField({
    required this.label,
    required this.items,
    this.initialValue,
    this.onChanged,
    super.key,
  });

  final String label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Select ${widget.label}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items
                  .map((item) => ListTile(
                        title: Text(item),
                        onTap: () => Navigator.pop(context, item),
                      ))
                  .toList(),
            ),
          ),
        );
        if (selected != null) {
          setState(() => _selectedValue = selected);
          widget.onChanged?.call(selected);
        }
      },
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
                  _selectedValue,
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
