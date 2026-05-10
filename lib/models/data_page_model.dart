import 'package:flutter/material.dart';

class DataPageModel {
  final bool mock;
  final DateTime? generatedAt;
  final DailyGlucoseData currentGlucose;
  final MetabolicScoreData metabolicScore;
  final CalendarData calendar;
  final DailyStatsData stats;

  DataPageModel({
    required this.mock,
    required this.generatedAt,
    required this.currentGlucose,
    required this.metabolicScore,
    required this.calendar,
    required this.stats,
  });

  factory DataPageModel.fromJson(Map<String, dynamic> json) {
    return DataPageModel(
      mock: json['mock'] == true,
      generatedAt: json['generatedAt'] is String
          ? DateTime.tryParse(json['generatedAt'] as String)
          : null,
      currentGlucose: DailyGlucoseData.fromJson(
        Map<String, dynamic>.from(json['currentGlucose'] as Map? ?? {}),
      ),
      metabolicScore: MetabolicScoreData.fromJson(
        Map<String, dynamic>.from(json['metabolicScore'] as Map? ?? {}),
      ),
      calendar: CalendarData.fromJson(
        Map<String, dynamic>.from(json['calendar'] as Map? ?? {}),
      ),
      stats: DailyStatsData.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? {}),
      ),
    );
  }
}

class DailyGlucoseData {
  final int value;
  final String unit;
  final String trend;
  final String timestamp;
  final bool hasAlert;
  final String? alertMessage;

  DailyGlucoseData({
    required this.value,
    required this.unit,
    required this.trend,
    required this.timestamp,
    required this.hasAlert,
    this.alertMessage,
  });

  factory DailyGlucoseData.fromJson(Map<String, dynamic> json) {
    return DailyGlucoseData(
      value: (json['value'] as num?)?.toInt() ?? 102,
      unit: json['unit'] as String? ?? 'mg/dL',
      trend: json['trend'] as String? ?? '↑',
      timestamp: json['timestamp'] as String? ?? '10:02 am',
      hasAlert: json['hasAlert'] == true,
      alertMessage: json['alertMessage'] as String?,
    );
  }
}

class MetabolicScoreData {
  final int score;
  final String description;
  final String percentile;

  MetabolicScoreData({
    required this.score,
    required this.description,
    required this.percentile,
  });

  factory MetabolicScoreData.fromJson(Map<String, dynamic> json) {
    return MetabolicScoreData(
      score: (json['score'] as num?)?.toInt() ?? 81,
      description: json['description'] as String? ?? 'Your Metabolic Score is in the',
      percentile: json['percentile'] as String? ?? 'top 40% of all Users',
    );
  }
}

class CalendarData {
  final int year;
  final int month;
  final List<CalendarDay> days;

  CalendarData({
    required this.year,
    required this.month,
    required this.days,
  });

  factory CalendarData.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['days'] as List?) ?? const [];
    return CalendarData(
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      days: rawDays
          .whereType<Map>()
          .map((day) => CalendarDay.fromJson(Map<String, dynamic>.from(day)))
          .toList(),
    );
  }
}

class CalendarDay {
  final int day;
  final int? glucose;
  final String status; // 'optimal', 'high', 'low', 'empty'

  CalendarDay({
    required this.day,
    required this.glucose,
    required this.status,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      day: (json['day'] as num?)?.toInt() ?? 0,
      glucose: (json['glucose'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'empty',
    );
  }

  Color getColor() {
    switch (status) {
      case 'optimal':
        return const Color(0xFFB7E7C4);
      case 'high':
        return const Color(0xFFFFD1D1);
      case 'low':
        return const Color(0xFFFFE4B5);
      default:
        return const Color(0xFFE6E6E9);
    }
  }
}

class DailyStatsData {
  final int avgGlucose;
  final int stdDev;
  final String spikeTime;
  final int spikeCount;

  DailyStatsData({
    required this.avgGlucose,
    required this.stdDev,
    required this.spikeTime,
    required this.spikeCount,
  });

  factory DailyStatsData.fromJson(Map<String, dynamic> json) {
    return DailyStatsData(
      avgGlucose: (json['avgGlucose'] as num?)?.toInt() ?? 108,
      stdDev: (json['stdDev'] as num?)?.toInt() ?? 7,
      spikeTime: json['spikeTime'] as String? ?? '1h 40m',
      spikeCount: (json['spikeCount'] as num?)?.toInt() ?? 1,
    );
  }
}

class GlucoseEvent {
  final String id;
  final String type;
  final String title;
  final String description;
  final int glucoseValue;
  final String timestamp;
  final String? detailedInfo;

  GlucoseEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.glucoseValue,
    required this.timestamp,
    this.detailedInfo,
  });

  factory GlucoseEvent.fromJson(Map<String, dynamic> json) {
    return GlucoseEvent(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'hyperglycemic',
      title: json['title'] as String? ?? 'Hyperglycemic event detected',
      description: json['description'] as String? ?? '',
      glucoseValue: (json['glucoseValue'] as num?)?.toInt() ?? 120,
      timestamp: json['timestamp'] as String? ?? '10:56 pm',
      detailedInfo: json['detailedInfo'] as String?,
    );
  }
}
