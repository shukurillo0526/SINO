import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching anonymized analytics data for B2B dashboard.
/// All data is aggregated - no individual student information is exposed.
class AnalyticsService {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Fetches daily mood aggregates for the past N days
  Future<List<DailyMoodStats>> fetchDailyMoodStats({int days = 14}) async {
    try {
      final response = await _supabase
          .from('analytics_daily_mood')
          .select()
          .gte('date', DateTime.now().subtract(Duration(days: days)).toIso8601String())
          .order('date', ascending: true);

      return (response as List).map((e) => DailyMoodStats.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching daily mood stats: $e');
      return _getMockDailyStats(days);
    }
  }

  /// Fetches current risk distribution across student body
  Future<RiskDistribution> fetchRiskDistribution() async {
    try {
      final response = await _supabase
          .from('analytics_risk_distribution')
          .select();

      final data = response as List;
      int highRisk = 0, moderateRisk = 0, neutral = 0, positive = 0;

      for (var item in data) {
        final tier = item['risk_tier'] as String;
        final count = item['user_count'] as int;
        switch (tier) {
          case 'high_risk':
            highRisk = count;
            break;
          case 'moderate_risk':
            moderateRisk = count;
            break;
          case 'neutral':
            neutral = count;
            break;
          case 'positive':
            positive = count;
            break;
        }
      }

      return RiskDistribution(
        highRisk: highRisk,
        moderateRisk: moderateRisk,
        neutral: neutral,
        positive: positive,
      );
    } catch (e) {
      debugPrint('Error fetching risk distribution: $e');
      return _getMockRiskDistribution();
    }
  }

  /// Fetches weekly wellness trends
  Future<List<WeeklyTrend>> fetchWeeklyTrends({int weeks = 8}) async {
    try {
      final response = await _supabase
          .from('analytics_weekly_trends')
          .select()
          .limit(weeks);

      return (response as List).map((e) => WeeklyTrend.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching weekly trends: $e');
      return _getMockWeeklyTrends(weeks);
    }
  }

  /// Fetches mood entry source breakdown
  Future<List<SourceBreakdown>> fetchSourceBreakdown() async {
    try {
      final response = await _supabase
          .from('analytics_source_breakdown')
          .select();

      return (response as List).map((e) => SourceBreakdown.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching source breakdown: $e');
      return _getMockSourceBreakdown();
    }
  }

  /// Fetches academic stress correlation data
  Future<List<WorkloadMoodCorrelation>> fetchAcademicStressCorrelation() async {
    try {
      final response = await _supabase
          .from('analytics_academic_stress')
          .select();

      return (response as List).map((e) => WorkloadMoodCorrelation.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching academic stress data: $e');
      return _getMockWorkloadCorrelation();
    }
  }

  // ===== MOCK DATA (for demo/development) =====

  List<DailyMoodStats> _getMockDailyStats(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - i - 1));
      final sentiment = 0.1 + (i % 5) * 0.1 - 0.2;
      return DailyMoodStats(
        date: date,
        entryCount: 15 + (i % 10),
        avgSentiment: sentiment,
        concernCount: sentiment < 0 ? 3 : 1,
        positiveCount: sentiment > 0 ? 8 : 4,
      );
    });
  }

  RiskDistribution _getMockRiskDistribution() {
    return RiskDistribution(
      highRisk: 5,
      moderateRisk: 12,
      neutral: 45,
      positive: 38,
    );
  }

  List<WeeklyTrend> _getMockWeeklyTrends(int weeks) {
    final now = DateTime.now();
    return List.generate(weeks, (i) {
      final weekStart = now.subtract(Duration(days: 7 * (weeks - i - 1)));
      return WeeklyTrend(
        weekStart: weekStart,
        activeUsers: 80 + (i * 5),
        totalEntries: 200 + (i * 20),
        avgSentiment: 0.15 + (i * 0.02),
        sentimentVariance: 0.3,
      );
    });
  }

  List<SourceBreakdown> _getMockSourceBreakdown() {
    return [
      SourceBreakdown(source: 'manual', entryCount: 120, avgSentiment: 0.1),
      SourceBreakdown(source: 'character', entryCount: 85, avgSentiment: 0.25),
      SourceBreakdown(source: 'academics', entryCount: 60, avgSentiment: -0.1),
      SourceBreakdown(source: 'mindfulness', entryCount: 40, avgSentiment: 0.4),
      SourceBreakdown(source: 'voice', entryCount: 25, avgSentiment: 0.05),
    ];
  }

  List<WorkloadMoodCorrelation> _getMockWorkloadCorrelation() {
    return [
      WorkloadMoodCorrelation(workloadTier: 'high_workload', userCount: 8, avgSentiment: -0.35),
      WorkloadMoodCorrelation(workloadTier: 'moderate_workload', userCount: 25, avgSentiment: -0.1),
      WorkloadMoodCorrelation(workloadTier: 'on_track', userCount: 67, avgSentiment: 0.25),
    ];
  }
}

// ===== DATA MODELS =====

class DailyMoodStats {
  final DateTime date;
  final int entryCount;
  final double avgSentiment;
  final int concernCount;
  final int positiveCount;

  DailyMoodStats({
    required this.date,
    required this.entryCount,
    required this.avgSentiment,
    required this.concernCount,
    required this.positiveCount,
  });

  factory DailyMoodStats.fromJson(Map<String, dynamic> json) => DailyMoodStats(
    date: DateTime.parse(json['date']),
    entryCount: json['entry_count'] ?? 0,
    avgSentiment: (json['avg_sentiment'] ?? 0.0).toDouble(),
    concernCount: json['concern_count'] ?? 0,
    positiveCount: json['positive_count'] ?? 0,
  );
}

class RiskDistribution {
  final int highRisk;
  final int moderateRisk;
  final int neutral;
  final int positive;

  RiskDistribution({
    required this.highRisk,
    required this.moderateRisk,
    required this.neutral,
    required this.positive,
  });

  int get total => highRisk + moderateRisk + neutral + positive;

  double get highRiskPercent => total > 0 ? (highRisk / total) * 100 : 0;
  double get moderateRiskPercent => total > 0 ? (moderateRisk / total) * 100 : 0;
  double get neutralPercent => total > 0 ? (neutral / total) * 100 : 0;
  double get positivePercent => total > 0 ? (positive / total) * 100 : 0;
}

class WeeklyTrend {
  final DateTime weekStart;
  final int activeUsers;
  final int totalEntries;
  final double avgSentiment;
  final double sentimentVariance;

  WeeklyTrend({
    required this.weekStart,
    required this.activeUsers,
    required this.totalEntries,
    required this.avgSentiment,
    required this.sentimentVariance,
  });

  factory WeeklyTrend.fromJson(Map<String, dynamic> json) => WeeklyTrend(
    weekStart: DateTime.parse(json['week_start']),
    activeUsers: json['active_users'] ?? 0,
    totalEntries: json['total_entries'] ?? 0,
    avgSentiment: (json['avg_sentiment'] ?? 0.0).toDouble(),
    sentimentVariance: (json['sentiment_variance'] ?? 0.0).toDouble(),
  );
}

class SourceBreakdown {
  final String source;
  final int entryCount;
  final double avgSentiment;

  SourceBreakdown({
    required this.source,
    required this.entryCount,
    required this.avgSentiment,
  });

  factory SourceBreakdown.fromJson(Map<String, dynamic> json) => SourceBreakdown(
    source: json['source'] ?? 'unknown',
    entryCount: json['entry_count'] ?? 0,
    avgSentiment: (json['avg_sentiment'] ?? 0.0).toDouble(),
  );

  String get displayName {
    switch (source) {
      case 'manual': return 'Manual Entry';
      case 'character': return 'SINO Chat';
      case 'academics': return 'Academics';
      case 'mindfulness': return 'Mindfulness';
      case 'voice': return 'Voice Notes';
      case 'games': return 'Games';
      default: return source;
    }
  }
}

class WorkloadMoodCorrelation {
  final String workloadTier;
  final int userCount;
  final double avgSentiment;

  WorkloadMoodCorrelation({
    required this.workloadTier,
    required this.userCount,
    required this.avgSentiment,
  });

  factory WorkloadMoodCorrelation.fromJson(Map<String, dynamic> json) => WorkloadMoodCorrelation(
    workloadTier: json['workload_tier'] ?? 'unknown',
    userCount: json['user_count'] ?? 0,
    avgSentiment: (json['avg_sentiment'] ?? 0.0).toDouble(),
  );

  String get displayName {
    switch (workloadTier) {
      case 'high_workload': return 'High Workload';
      case 'moderate_workload': return 'Moderate';
      case 'on_track': return 'On Track';
      default: return workloadTier;
    }
  }
}
