import 'package:flutter/material.dart';

import '../../widgets/navigation/app_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isQuickMenuOpen = false;

  static const _titles = ['Monitor', 'Data', 'Discover', 'Profile'];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _isQuickMenuOpen = false;
    });
  }

  void _onCenterTap() {
    setState(() {
      _isQuickMenuOpen = !_isQuickMenuOpen;
    });
  }

  void _onQuickActionTap(QuickActionType action) {
    setState(() {
      _isQuickMenuOpen = false;
    });

    final label = switch (action) {
      QuickActionType.diet => 'Diet',
      QuickActionType.insulin => 'Insulin',
      QuickActionType.medicine => 'Medicine',
      QuickActionType.exercise => 'Exercise',
      QuickActionType.fingerBlood => 'Finger Blood',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label selected.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F3F4),
        elevation: 0,
        centerTitle: false,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _isQuickMenuOpen ? _onCenterTap : null,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Dashboard'),
                const SizedBox(height: 12),
                _OverviewCard(tabTitle: _titles[_currentIndex]),
                const SizedBox(height: 14),
                const _SectionHeader(title: 'Upcoming Modules'),
                const SizedBox(height: 10),
                const _ModuleTile(label: 'Glucose timeline card'),
                const _ModuleTile(label: 'Health metrics summary'),
                const _ModuleTile(label: 'Sensor connection status'),
                const _ModuleTile(label: 'Medication and meal logs'),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE3E3E3)),
                  ),
                  child: const Text(
                    'This is your base dashboard shell. We can now add each feature one by one.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B5F66),
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        onCenterTap: _onCenterTap,
        isActionMenuOpen: _isQuickMenuOpen,
        onQuickActionTap: _onQuickActionTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.tabTitle});

  final String tabTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$tabTitle section is ready',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We can now plug real cards/widgets here as we build each module.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6C717B),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E6E9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF9AA1AC), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF32353A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
