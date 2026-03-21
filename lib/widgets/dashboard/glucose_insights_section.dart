import 'package:flutter/material.dart';

import '../../models/dashboard_data.dart';

class GlucoseInsightsSection extends StatelessWidget {
  const GlucoseInsightsSection({
    super.key,
    this.topStats = const [],
    this.cards = const [],
  });

  final List<InsightTopStat> topStats;
  final List<InsightCardItem> cards;

  @override
  Widget build(BuildContext context) {
    final safeTopStats = topStats.isEmpty ? _defaultTopStats : topStats;
    final safeCards = cards.isEmpty ? _defaultCards : cards;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 6),
          _TopStatsRow(stats: safeTopStats),
          const SizedBox(height: 18),
          ...safeCards.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: entry.key == safeCards.length - 1 ? 0 : 12),
              child: _InsightCard(data: entry.value),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow({required this.stats});

  final List<InsightTopStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stats.length, (index) {
        final item = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == stats.length - 1 ? 0 : 4,
            ),
            child: _MiniStat(
              value: item.value,
              unit: item.unit,
              label: item.label,
              valueColor: item.valueColor,
            ),
          ),
        );
      }),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.unit,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String unit;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isCompact ? 22 : 24,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6E737D),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 15 : 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6E737D),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});

  final InsightCardItem data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.05,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.status,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00A85A),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    data.unit,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _RangeScale(),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Optimal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D7178),
                ),
              ),
              Text(
                'Elevated',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D7178),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.summary,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

const _defaultTopStats = <InsightTopStat>[
  InsightTopStat(
    key: 'avgGlucose',
    value: '18',
    unit: 'mg/dL',
    label: 'Avg Glucose',
    valueColor: Color(0xFF111111),
  ),
  InsightTopStat(
    key: 'stdDev',
    value: '17',
    unit: 'mg/dL',
    label: 'Std. Dev',
    valueColor: Color(0xFF111111),
  ),
  InsightTopStat(
    key: 'spikeTime',
    value: '1h 40m',
    unit: '',
    label: 'Spike Time',
    valueColor: Color(0xFFD92D20),
  ),
  InsightTopStat(
    key: 'spike',
    value: '1',
    unit: '',
    label: 'Spike',
    valueColor: Color(0xFFD92D20),
  ),
];

const _defaultCards = <InsightCardItem>[
  InsightCardItem(
    title: 'Time above range',
    value: '45',
    unit: 'min',
    status: 'OPTIMAL',
    summary:
        'Your glucose levels have been stable today. Focus on balanced meals and activity to help your body to balance glucose.',
  ),
  InsightCardItem(
    title: 'Time in range',
    value: '45',
    unit: 'min',
    status: 'OPTIMAL',
    summary:
        'Your glucose levels have been stable today. Focus on balanced meals and activity to help your body to balance glucose.',
  ),
  InsightCardItem(
    title: 'Glucose Excursion',
    value: '45',
    unit: 'min',
    status: 'OPTIMAL',
    summary:
        'Your glucose levels have been stable today. Focus on balanced meals and activity to help your body to balance glucose.',
  ),
  InsightCardItem(
    title: 'GMI',
    value: '6.4',
    unit: '%',
    status: 'OPTIMAL',
    summary:
        'Your glucose levels have been stable today. Focus on balanced meals and activity to help your body to balance glucose.',
  ),
  InsightCardItem(
    title: 'Glucose Oscillation’s',
    value: '45',
    unit: 'min',
    status: 'OPTIMAL',
    summary:
        'Your glucose levels have been stable today. Focus on balanced meals and activity to help your body to balance glucose.',
  ),
];

class _RangeScale extends StatelessWidget {
  const _RangeScale();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(left: 34),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A85A),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBCDD1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBCDD1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBCDD1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
