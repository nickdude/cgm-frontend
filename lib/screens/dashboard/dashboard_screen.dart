import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_data.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';
import '../../widgets/dashboard/weekly_glucose_card.dart';
import '../../widgets/dashboard/glucose_gauge_card.dart';
import '../../widgets/dashboard/metabolic_score_card.dart';
import '../../widgets/dashboard/interactive_glucose_timeline_card.dart';
import '../../widgets/dashboard/glucose_insights_section.dart';
import '../../widgets/dashboard/event_timeline_section.dart';
import '../data/data_tab_content.dart';
import '../discover/discover_tab_content.dart';
import '../profile/profile_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isQuickMenuOpen = false;
  String? _lastLoadedUserId;

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
    _openQuickActionRoute(action);
  }

  Future<void> _openQuickActionRoute(QuickActionType action, {int? actionEpochMs}) async {
    final route = switch (action) {
      QuickActionType.diet => '/diet',
      QuickActionType.insulin => '/insulin',
      QuickActionType.medicine => '/medicine',
      QuickActionType.exercise => '/exercise',
      QuickActionType.fingerBlood => '/finger-blood',
    };

    final target = actionEpochMs == null ? route : '$route?actionEpoch=$actionEpochMs';

    setState(() {
      _isQuickMenuOpen = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await context.push(target);
    if (!mounted) return;
    await _loadDashboard(force: true);
  }

  Future<void> _onTimelineAddQuickAction(int selectedEpochMs) async {
    final selected = await showModalBottomSheet<QuickActionType>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Widget tile(QuickActionType type, String label, IconData icon) {
          return ListTile(
            leading: Icon(icon, color: const Color(0xFF38404A)),
            title: Text(label),
            onTap: () => Navigator.of(context).pop(type),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DCE1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add quick action',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              tile(QuickActionType.diet, 'Diet', Icons.restaurant),
              tile(QuickActionType.insulin, 'Insulin', Icons.vaccines),
              tile(QuickActionType.medicine, 'Medicine', Icons.medication),
              tile(QuickActionType.exercise, 'Exercise', Icons.directions_run),
              tile(QuickActionType.fingerBlood, 'Finger Blood', Icons.water_drop),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    await _openQuickActionRoute(selected, actionEpochMs: selectedEpochMs);
  }

  String _resolveUserId() {
    final userId = context.read<AuthProvider>().user?.id;
    return (userId != null && userId.isNotEmpty) ? userId : 'guest-dashboard';
  }

  Future<void> _loadDashboard({bool force = false}) async {
    final userId = _resolveUserId();
    if (!force && _lastLoadedUserId == userId) {
      return;
    }

    _lastLoadedUserId = userId;
    await context.read<DashboardProvider>().loadDashboard(userId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboard = dashboardProvider.dashboardData;
    final isLoading = dashboardProvider.isLoading;
    final error = dashboardProvider.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      extendBody: true,
    //   appBar: AppBar(
    //     backgroundColor: const Color(0xFFF3F3F4),
    //     elevation: 0,
    //     centerTitle: false,
    //     title: Text(
    //       _titles[_currentIndex],
    //       style: const TextStyle(
    //         color: Color(0xFF111111),
    //         fontSize: 24,
    //         fontWeight: FontWeight.w700,
    //       ),
    //     ),
    //   ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _isQuickMenuOpen ? _onCenterTap : null,
            child: SafeArea(
              top: true,
              child: RefreshIndicator(
                onRefresh: () => _loadDashboard(force: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // const _SectionHeader(title: 'Dashboard'),
                // const SizedBox(height: 12),
                // _OverviewCard(tabTitle: _titles[_currentIndex]),
                const SizedBox(height: 20),
                if (_currentIndex == 0) ..._buildMonitorContent(
                  context,
                  dashboard: dashboard,
                  isLoading: isLoading,
                  error: error,
                  onTimelineAddQuickAction: _onTimelineAddQuickAction,
                ) else if (_currentIndex == 1) const DataTabContent() else if (_currentIndex == 2) const DiscoverTabContent() else if (_currentIndex == 3) const ProfileHomeScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 90 + bottomInset,
            child: IgnorePointer(
              ignoring: !_isQuickMenuOpen,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                offset: _isQuickMenuOpen ? Offset.zero : const Offset(0, 0.12),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _isQuickMenuOpen ? 1 : 0,
                  child: Align(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 286),
                      child: QuickActionMenu(onActionTap: _onQuickActionTap),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

List<Widget> _buildPlaceholderTab({
  required String title,
  required String subtitle,
}) {
  return [
    const SizedBox(height: 80),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3E3E3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C717B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 40),
  ];
}

List<Widget> _buildMonitorContent(
  BuildContext context, {
  required DashboardData? dashboard,
  required bool isLoading,
  required String? error,
  required ValueChanged<int> onTimelineAddQuickAction,
}) {
  if (isLoading && dashboard == null) {
    return const [
      SizedBox(height: 80),
      Center(child: CircularProgressIndicator()),
      SizedBox(height: 80),
    ];
  }

  if (error != null && dashboard == null) {
    return [
      const SizedBox(height: 18),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3E3E3)),
          ),
          child: Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5B5F66),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  final weeklyPoints = (dashboard?.weekly.points ?? const <WeeklyPoint>[])
      .map((item) => WeeklyGlucoseData(day: item.day, value: item.value))
      .toList();

  return [
    WeeklyGlucoseCard(
      weeklyData: weeklyPoints,
      initialSelectedIndex: dashboard?.weekly.selectedIndex ?? 0,
      onDaySelected: (index) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day ${index + 1} selected'),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
    ),
    const SizedBox(height: 24),
    GlucoseGaugeCard(
      glucoseValue: dashboard?.gauge.glucoseValue ?? 102,
      unit: dashboard?.gauge.unit ?? 'mg/dL',
      isControlled: dashboard?.gauge.isControlled ?? true,
    ),
    const SizedBox(height: 24),
    MetabolicScoreCard(
      score: dashboard?.metabolicScore.score ?? 86,
      timestamp: dashboard?.metabolicScore.timestamp ?? '74 mg/dL · 5:22 pm',
      isImproved: dashboard?.metabolicScore.isImproved ?? true,
      label: dashboard?.metabolicScore.label ?? 'Metabolic Score',
    ),
    const SizedBox(height: 24),
    InteractiveGlucoseTimelineCard(
      points: dashboard?.timeline.points ?? const [],
      biomarkers: dashboard?.timeline.biomarkers ?? const [],
      onAddQuickAction: onTimelineAddQuickAction,
    ),
    const SizedBox(height: 16),
    GlucoseInsightsSection(
      topStats: dashboard?.insights.topStats ?? const [],
      cards: dashboard?.insights.cards ?? const [],
    ),
    const SizedBox(height: 22),
    DashboardEventTimelineSection(
      title: dashboard?.eventTimeline.title ?? 'Timeline',
      items: dashboard?.eventTimeline.items ?? const [],
    ),
    const SizedBox(height: 40),
  ];
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

