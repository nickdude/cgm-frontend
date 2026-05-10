import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool _alarmEnabled = true;
  bool _doNotDisturbEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111111), size: 22),
        ),
        title: const Text(
          'Alarm',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _AlarmToggleCard(
              title: 'Alarm',
              description: 'Turn off if you want to silence sounds & vibration alerts.',
              value: _alarmEnabled,
              onChanged: (value) => setState(() => _alarmEnabled = value),
            ),
            const SizedBox(height: 16),
            _AlarmScheduleCard(
              doNotDisturbEnabled: _doNotDisturbEnabled,
              onDoNotDisturbChanged: (value) => setState(() => _doNotDisturbEnabled = value),
              onStartTimeTap: () {},
              onEndTimeTap: () {},
            ),
            const SizedBox(height: 16),
            const _UrgentLowCard(),
          ],
        ),
      ),
    );
  }
}

class _AlarmToggleCard extends StatelessWidget {
  const _AlarmToggleCard({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C717B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF25C45A),
            activeTrackColor: const Color(0xFFBFEFCF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD4D4D8),
          ),
        ],
      ),
    );
  }
}

class _AlarmScheduleCard extends StatelessWidget {
  const _AlarmScheduleCard({
    required this.doNotDisturbEnabled,
    required this.onDoNotDisturbChanged,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
  });

  final bool doNotDisturbEnabled;
  final ValueChanged<bool> onDoNotDisturbChanged;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Do not disturb',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Notifications will not be sent during the set time',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6C717B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: doNotDisturbEnabled,
                  onChanged: onDoNotDisturbChanged,
                  activeColor: const Color(0xFF25C45A),
                  activeTrackColor: const Color(0xFFBFEFCF),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD4D4D8),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE9E9EC)),
          _SettingsRow(
            label: 'Start Time',
            onTap: onStartTimeTap,
          ),
          const Divider(height: 1, color: Color(0xFFE9E9EC)),
          _SettingsRow(
            label: 'End Time',
            onTap: onEndTimeTap,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA0A6), size: 26),
          ],
        ),
      ),
    );
  }
}

class _UrgentLowCard extends StatelessWidget {
  const _UrgentLowCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Urgent Low',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'This alarm will always play a sound even if your phone is muted or Do Not Disturb is ON. When glucose goes below the Alarm Value, you will receive a notification.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6C717B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E3E3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Alarm Value',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C717B),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '3.1',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 4),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text(
                        'mmol/L',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _StyleBox(
                  title: 'Alarm Style',
                  items: ['Sound', 'Vibration'],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SoundBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StyleBox extends StatelessWidget {
  const _StyleBox({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C717B),
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  const Icon(Icons.check_box_rounded, size: 18, color: Color(0xFF111111)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundBox extends StatelessWidget {
  const _SoundBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Sound',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C717B),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ambulance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF9AA0A6)),
            ],
          ),
        ],
      ),
    );
  }
}