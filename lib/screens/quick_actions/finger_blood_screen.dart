import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/quick_action_header.dart';

class FingerBloodScreen extends StatefulWidget {
  const FingerBloodScreen({super.key});

  @override
  State<FingerBloodScreen> createState() => _FingerBloodScreenState();
}

class _FingerBloodScreenState extends State<FingerBloodScreen> {
  final _bgmController = TextEditingController();
  String _bloodTime = '08-03 17:28';
  String _bloodStatus = 'Before Dinner';

  @override
  void dispose() {
    _bgmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: QuickActionHeader(
          title: 'Finger Blood',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BGM in one card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BGM (mmol/L)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bgmController,
                        decoration: InputDecoration(
                          hintText: 'Enter blood glucose measurement',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFA8A8A8),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Time and Status in one card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && mounted) {
                          final timePicked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (timePicked != null) {
                            setState(() {
                              _bloodTime =
                                  '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')} ${timePicked.hour.toString().padLeft(2, '0')}:${timePicked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111111),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _bloodTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFA8A8A8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Color(0xFFC8C8C8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: const Color(0xFFE8E8E8),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final items = [
                          'Before Breakfast',
                          'After Breakfast',
                          'Before Lunch',
                          'After Lunch',
                          'Before Dinner',
                          'After Dinner',
                          'Bedtime',
                        ];
                        final selected = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Status'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: items
                                  .map((item) => ListTile(
                                        title: Text(item),
                                        onTap: () =>
                                            Navigator.pop(context, item),
                                      ))
                                  .toList(),
                            ),
                          ),
                        );
                        if (selected != null) {
                          setState(() => _bloodStatus = selected);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111111),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _bloodStatus,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFA8A8A8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Color(0xFFC8C8C8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_bgmController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter blood glucose measurement'),
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Blood glucose saved successfully!'),
                      ),
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
