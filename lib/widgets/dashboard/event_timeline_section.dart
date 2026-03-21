import 'package:flutter/material.dart';

import '../../models/dashboard_data.dart';

class DashboardEventTimelineSection extends StatelessWidget {
  const DashboardEventTimelineSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<EventTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 44 / 2,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D0D0D),
            ),
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: entry.key == items.length - 1 ? 0 : 12),
                  child: _TimelineEventCard(item: entry.value),
                ),
              ),
        ],
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({required this.item});

  final EventTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final isAlert = item.level.toLowerCase() == 'alert';
    final isGood = item.level.toLowerCase() == 'good';

    final leadingColor = isAlert
        ? const Color(0xFFE53935)
        : isGood
            ? const Color(0xFF11A861)
            : const Color(0xFF0D0D0D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0D7E2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_leadingIcon(item.icon), size: 21, color: leadingColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.time} • ${item.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 38 / 2,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101114),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.info, size: 18, color: Color(0xFF6F7178)),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFD0D7E2)),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 30 / 2,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6A6D74),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _leadingIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'meal':
        return Icons.restaurant;
      case 'pulse':
        return Icons.monitor_heart;
      case 'check':
        return Icons.check_circle_outline;
      case 'warning':
      default:
        return Icons.error_outline;
    }
  }
}
