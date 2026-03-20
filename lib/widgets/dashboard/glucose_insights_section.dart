import 'package:flutter/material.dart';

class GlucoseInsightsSection extends StatelessWidget {
  const GlucoseInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _InsightCardData(title: 'Time above range', value: '45', unit: 'min'),
      _InsightCardData(title: 'Time in range', value: '45', unit: 'min'),
      _InsightCardData(title: 'Glucose Excursion', value: '45', unit: 'min'),
      _InsightCardData(title: 'GMI', value: '45', unit: 'min'),
      _InsightCardData(title: 'Glucose Oscillation’s', value: '45', unit: 'min'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const _TopStatsRow(),
          const SizedBox(height: 14),
          ...cards.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: entry.key == cards.length - 1 ? 0 : 12),
              child: _InsightCard(data: entry.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MiniStat(
            value: '108',
            unit: 'mg/dL',
            label: 'Avg Glucose',
            valueColor: Color(0xFF111111),
          ),
        ),
        Expanded(
          child: _MiniStat(
            value: '7',
            unit: 'mg/dL',
            label: 'Std. Dev',
            valueColor: Color(0xFF111111),
          ),
        ),
        Expanded(
          child: _MiniStat(
            value: '1h 40m',
            unit: '',
            label: 'Spike Time',
            valueColor: Color(0xFFD92D20),
          ),
        ),
        Expanded(
          child: _MiniStat(
            value: '1',
            unit: '',
            label: 'Spike',
            valueColor: Color(0xFFD92D20),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _InsightCardData {
  const _InsightCardData({
    required this.title,
    required this.value,
    required this.unit,
  });

  final String title;
  final String value;
  final String unit;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});

  final _InsightCardData data;

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
                    const Text(
                      'OPTIMAL',
                      style: TextStyle(
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
          const Text(
            'Your glucose levels have been stable today.\nFocus on balanced meals and activity to help your\nbody to balance glucose.',
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
