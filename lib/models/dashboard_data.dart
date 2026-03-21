import 'package:flutter/material.dart';

class DashboardData {
  final bool mock;
  final DateTime? generatedAt;
  final WeeklySection weekly;
  final GaugeSection gauge;
  final MetabolicScoreSection metabolicScore;
  final TimelineSection timeline;
  final InsightsSection insights;
  final EventTimelineSection eventTimeline;

  DashboardData({
    required this.mock,
    required this.generatedAt,
    required this.weekly,
    required this.gauge,
    required this.metabolicScore,
    required this.timeline,
    required this.insights,
    required this.eventTimeline,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final parsedEventTimeline = _safeEventTimeline(json['eventTimeline']);

    return DashboardData(
      mock: json['mock'] == true,
      generatedAt: json['generatedAt'] is String
          ? DateTime.tryParse(json['generatedAt'] as String)
          : null,
      weekly: WeeklySection.fromJson(Map<String, dynamic>.from(json['weekly'] as Map? ?? {})),
      gauge: GaugeSection.fromJson(Map<String, dynamic>.from(json['gauge'] as Map? ?? {})),
      metabolicScore: MetabolicScoreSection.fromJson(
        Map<String, dynamic>.from(json['metabolicScore'] as Map? ?? {}),
      ),
      timeline: TimelineSection.fromJson(Map<String, dynamic>.from(json['timeline'] as Map? ?? {})),
      insights: InsightsSection.fromJson(Map<String, dynamic>.from(json['insights'] as Map? ?? {})),
      eventTimeline: parsedEventTimeline,
    );
  }

  static EventTimelineSection _safeEventTimeline(dynamic raw) {
    try {
      if (raw is Map) {
        return EventTimelineSection.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {
      // fall back to default section
    }

    return const EventTimelineSection(title: 'Timeline', items: []);
  }
}

class WeeklySection {
  final int selectedIndex;
  final List<WeeklyPoint> points;

  WeeklySection({required this.selectedIndex, required this.points});

  factory WeeklySection.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as List?) ?? const [];
    return WeeklySection(
      selectedIndex: (json['selectedIndex'] as num?)?.toInt() ?? 0,
      points: rawPoints
          .whereType<Map>()
          .map((point) => WeeklyPoint.fromJson(Map<String, dynamic>.from(point)))
          .toList(),
    );
  }
}

class WeeklyPoint {
  final String day;
  final int? value;

  const WeeklyPoint({required this.day, required this.value});

  factory WeeklyPoint.fromJson(Map<String, dynamic> json) {
    return WeeklyPoint(
      day: (json['day'] as String? ?? '').trim(),
      value: (json['value'] as num?)?.toInt(),
    );
  }
}

class GaugeSection {
  final int glucoseValue;
  final String unit;
  final bool isControlled;
  final String trend;

  GaugeSection({
    required this.glucoseValue,
    required this.unit,
    required this.isControlled,
    required this.trend,
  });

  factory GaugeSection.fromJson(Map<String, dynamic> json) {
    return GaugeSection(
      glucoseValue: (json['glucoseValue'] as num?)?.toInt() ?? 0,
      unit: (json['unit'] as String? ?? 'mg/dL').trim(),
      isControlled: json['isControlled'] == true,
      trend: (json['trend'] as String? ?? 'up').trim(),
    );
  }
}

class MetabolicScoreSection {
  final int score;
  final bool isImproved;
  final String label;
  final String timestamp;

  MetabolicScoreSection({
    required this.score,
    required this.isImproved,
    required this.label,
    required this.timestamp,
  });

  factory MetabolicScoreSection.fromJson(Map<String, dynamic> json) {
    return MetabolicScoreSection(
      score: (json['score'] as num?)?.toInt() ?? 0,
      isImproved: json['isImproved'] != false,
      label: (json['label'] as String? ?? 'Metabolic Score').trim(),
      timestamp: (json['timestamp'] as String? ?? '74 mg/dL · 5:22 pm').trim(),
    );
  }
}

class TimelineSection {
  final String currentTimeLabel;
  final String highlightedValue;
  final List<String> timeTicks;
  final List<TimelinePoint> points;
  final List<TimelineBiomarker> biomarkers;

  TimelineSection({
    required this.currentTimeLabel,
    required this.highlightedValue,
    required this.timeTicks,
    required this.points,
    required this.biomarkers,
  });

  factory TimelineSection.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as List?) ?? const [];
    final rawBiomarkers = (json['biomarkers'] as List?) ?? const [];

    return TimelineSection(
      currentTimeLabel: (json['currentTimeLabel'] as String? ?? '10:25 am').trim(),
      highlightedValue: (json['highlightedValue'] as String? ?? '176 mg/dL').trim(),
      timeTicks: ((json['timeTicks'] as List?) ?? const ['6 am', '9 am', '12 pm', '3 pm'])
          .map((item) => item.toString())
          .toList(),
      points: rawPoints
          .whereType<Map>()
          .map((item) => TimelinePoint.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      biomarkers: rawBiomarkers
          .whereType<Map>()
          .map((item) => TimelineBiomarker.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class TimelinePoint {
  final int epochMs;
  final int glucoseValue;
  final String label;

  const TimelinePoint({
    required this.epochMs,
    required this.glucoseValue,
    required this.label,
  });

  factory TimelinePoint.fromJson(Map<String, dynamic> json) {
    return TimelinePoint(
      epochMs: (json['epochMs'] as num?)?.toInt() ?? 0,
      glucoseValue: (json['glucoseValue'] as num?)?.toInt() ?? 0,
      label: (json['label'] as String? ?? '').trim(),
    );
  }
}

class TimelineBiomarker {
  final int epochMs;
  final String actionType;
  final String icon;

  const TimelineBiomarker({
    required this.epochMs,
    required this.actionType,
    required this.icon,
  });

  factory TimelineBiomarker.fromJson(Map<String, dynamic> json) {
    return TimelineBiomarker(
      epochMs: (json['epochMs'] as num?)?.toInt() ?? 0,
      actionType: (json['actionType'] as String? ?? '').trim(),
      icon: (json['icon'] as String? ?? 'event').trim(),
    );
  }
}

class InsightsSection {
  final List<InsightTopStat> topStats;
  final List<InsightCardItem> cards;

  InsightsSection({required this.topStats, required this.cards});

  factory InsightsSection.fromJson(Map<String, dynamic> json) {
    final rawTopStats = (json['topStats'] as List?) ?? const [];
    final rawCards = (json['cards'] as List?) ?? const [];

    return InsightsSection(
      topStats: rawTopStats
          .whereType<Map>()
          .map((item) => InsightTopStat.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      cards: rawCards
          .whereType<Map>()
          .map((item) => InsightCardItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class InsightTopStat {
  final String key;
  final String value;
  final String unit;
  final String label;
  final Color valueColor;

  const InsightTopStat({
    required this.key,
    required this.value,
    required this.unit,
    required this.label,
    required this.valueColor,
  });

  factory InsightTopStat.fromJson(Map<String, dynamic> json) {
    return InsightTopStat(
      key: (json['key'] as String? ?? '').trim(),
      value: (json['value'] as String? ?? '').trim(),
      unit: (json['unit'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
      valueColor: _parseHexColor((json['valueColor'] as String?) ?? '#111111'),
    );
  }
}

class InsightCardItem {
  final String title;
  final String value;
  final String unit;
  final String status;
  final String summary;

  const InsightCardItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.summary,
  });

  factory InsightCardItem.fromJson(Map<String, dynamic> json) {
    return InsightCardItem(
      title: (json['title'] as String? ?? '').trim(),
      value: (json['value'] as String? ?? '').trim(),
      unit: (json['unit'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? 'OPTIMAL').trim(),
      summary: (json['summary'] as String? ?? '').trim(),
    );
  }
}

class EventTimelineSection {
  final String title;
  final List<EventTimelineItem> items;

  const EventTimelineSection({required this.title, required this.items});

  factory EventTimelineSection.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return EventTimelineSection(
      title: (json['title'] as String? ?? 'Timeline').trim(),
      items: rawItems
          .whereType<Map>()
          .map((item) => EventTimelineItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class EventTimelineItem {
  final String icon;
  final String level;
  final String time;
  final String title;
  final String description;

  const EventTimelineItem({
    required this.icon,
    required this.level,
    required this.time,
    required this.title,
    required this.description,
  });

  factory EventTimelineItem.fromJson(Map<String, dynamic> json) {
    return EventTimelineItem(
      icon: (json['icon'] as String? ?? 'warning').trim(),
      level: (json['level'] as String? ?? 'neutral').trim(),
      time: (json['time'] as String? ?? '').trim(),
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
    );
  }
}

Color _parseHexColor(String hex) {
  final normalized = hex.replaceAll('#', '').trim();
  if (normalized.length == 6) {
    return Color(int.parse('FF$normalized', radix: 16));
  }
  if (normalized.length == 8) {
    return Color(int.parse(normalized, radix: 16));
  }
  return const Color(0xFF111111);
}
