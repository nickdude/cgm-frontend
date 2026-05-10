import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/data_page_model.dart';
import '../../models/dashboard_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/events_provider.dart';
import '../../widgets/dashboard/weekly_glucose_card.dart';
import '../../widgets/dashboard/glucose_gauge_card.dart';
import '../../widgets/dashboard/metabolic_score_card.dart';

class DataTabContent extends StatefulWidget {
  const DataTabContent({super.key});

  @override
  State<DataTabContent> createState() => _DataTabContentState();
}

class _DataTabContentState extends State<DataTabContent> {
  String? _lastLoadedUserId;

  String _resolveUserId() {
    final userId = context.read<AuthProvider>().user?.id;
    return (userId != null && userId.isNotEmpty) ? userId : 'guest-data';
  }

  Future<void> _loadDataPage({bool force = false}) async {
    final userId = _resolveUserId();
    if (!force && _lastLoadedUserId == userId) {
      return;
    }

    _lastLoadedUserId = userId;
    await context.read<DataProvider>().loadDataPage(userId);
    await context.read<EventsProvider>().loadGlucoseEvents(userId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDataPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final data = dataProvider.dataPageModel;
    final isLoading = dataProvider.isLoading;
    final error = dataProvider.error;

    return RefreshIndicator(
      onRefresh: () => _loadDataPage(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (isLoading && data == null) ..._buildLoadingState()
            else if (error != null && data == null) ..._buildErrorState(error)
            else if (data != null) ..._buildDataContent(data),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoadingState() {
    return const [
      SizedBox(height: 80),
      Center(child: CircularProgressIndicator()),
      SizedBox(height: 80),
    ];
  }

  List<Widget> _buildErrorState(String error) {
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

  List<Widget> _buildDataContent(DataPageModel data) {
    // Build weekly points for WeeklyGlucoseCard (reuse Monitor component)
    final weeklyPoints = [
      WeeklyGlucoseData(day: 'W', value: 94),
      WeeklyGlucoseData(day: 'T', value: 79),
      WeeklyGlucoseData(day: 'F', value: 81),
      WeeklyGlucoseData(day: 'S', value: 90),
      WeeklyGlucoseData(day: 'S', value: null),
      WeeklyGlucoseData(day: 'M', value: null),
      WeeklyGlucoseData(day: 'T', value: null),
    ];

    return [
      // Weekly Glucose Card (reused from Monitor)
      WeeklyGlucoseCard(
        weeklyData: weeklyPoints,
        initialSelectedIndex: 3,
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
      // Glucose Gauge Card (reused from Monitor)
      GlucoseGaugeCard(
        glucoseValue: data.currentGlucose.value,
        unit: data.currentGlucose.unit,
        isControlled: !data.currentGlucose.hasAlert,
      ),
      const SizedBox(height: 24),
      // Metabolic Score Card (reused from Monitor)
      MetabolicScoreCard(
        score: data.metabolicScore.score,
        timestamp: data.metabolicScore.percentile,
        isImproved: true,
        label: 'Metabolic Score',
      ),
      const SizedBox(height: 24),
      // Calendar Section
      _buildCalendarCard(data.calendar),
      const SizedBox(height: 24),
      // Daily Stats Card
      _buildStatsCard(data.stats),
      const SizedBox(height: 40),
    ];
  }

  Widget _buildCalendarCard(CalendarData calendar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3E3E3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chevron_left, color: Color(0xFF9AA1AB)),
                  const SizedBox(width: 16),
                  Text(
                    'Jun ${calendar.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.info_outline, color: Color(0xFF9AA1AB), size: 18),
                  const SizedBox(width: 16),
                  const Icon(Icons.chevron_right, color: Color(0xFF9AA1AB)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCalendarGrid(calendar.days),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<CalendarDay> days) {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Column(
      children: [
        // Day headers
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels
                .map((label) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFAEB6BF),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        // Calendar days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return _buildCalendarCell(day);
          },
        ),
      ],
    );
  }

  Widget _buildCalendarCell(CalendarDay day) {
    if (day.day == 0) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        color: day.getColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: day.glucose != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.glucose}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              )
            : Text(
                '${day.day}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFAEB6BF),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsCard(DailyStatsData stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3E3E3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('${stats.avgGlucose}', 'Avg Glucose', 'mg/dL'),
            _buildStatDivider(),
            _buildStatItem('${stats.stdDev}', 'Std. Dev', 'mg/dL'),
            _buildStatDivider(),
            _buildStatItem(stats.spikeTime, 'Spike Time', ''),
            _buildStatDivider(),
            _buildStatItem('${stats.spikeCount}', 'Spike', ''),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9AA1AB),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C717B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: const Color(0xFFE6E6E9),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      progress * 2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
