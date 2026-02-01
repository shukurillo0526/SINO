import 'package:flutter/material.dart';

enum MoodLevel {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  anxious,
  stressed,
}

enum MoodSource {
  manual,
  character,
  games,
  mindfulness,
  academics,
  voice,
}

class MoodEntry {
  final String id;
  final DateTime timestamp;
  final MoodLevel mood;
  final MoodSource source;
  final double sentimentScore; // -1.0 (very negative) to 1.0 (very positive)
  final String? context;
  final Map<String, dynamic>? metadata;

  MoodEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.source,
    required this.sentimentScore,
    this.context,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'mood': mood.index,
    'source': source.index,
    'sentimentScore': sentimentScore,
    'context': context,
    'metadata': metadata,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    // Helper to get value from either snake_case or camelCase key
    T? get<T>(String snake, String camel) {
      return (json[snake] ?? json[camel]) as T?;
    }

    final moodVal = json['mood_level'] ?? json['mood'];
    final sourceVal = json['source'];
    
    return MoodEntry(
      id: json['id'],
      timestamp: DateTime.parse(get<String>('created_at', 'timestamp')!),
      mood: moodVal is int ? MoodLevel.values[moodVal] : MoodLevel.values[0],
      source: sourceVal is int 
          ? MoodSource.values[sourceVal] 
          : MoodSource.values.firstWhere((e) => e.name == sourceVal, orElse: () => MoodSource.manual),
      sentimentScore: (get<num>('sentiment_score', 'sentimentScore') ?? 0.0).toDouble(),
      context: json['context'],
      metadata: json['metadata'],
    );
  }
}

extension MoodLevelExtension on MoodLevel {
  String get emoji {
    switch (this) {
      case MoodLevel.veryHappy:
        return '😄';
      case MoodLevel.happy:
        return '😊';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.sad:
        return '😢';
      case MoodLevel.verySad:
        return '😭';
      case MoodLevel.anxious:
        return '😰';
      case MoodLevel.stressed:
        return '😫';
    }
  }

  String get label {
    switch (this) {
      case MoodLevel.veryHappy:
        return 'Very Happy';
      case MoodLevel.happy:
        return 'Happy';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.sad:
        return 'Sad';
      case MoodLevel.verySad:
        return 'Very Sad';
      case MoodLevel.anxious:
        return 'Anxious';
      case MoodLevel.stressed:
        return 'Stressed';
    }
  }

  Color get color {
    switch (this) {
      case MoodLevel.veryHappy:
        return const Color(0xFF4CAF50);
      case MoodLevel.happy:
        return const Color(0xFF8BC34A);
      case MoodLevel.neutral:
        return const Color(0xFF9E9E9E);
      case MoodLevel.sad:
        return const Color(0xFFFF9800);
      case MoodLevel.verySad:
        return const Color(0xFFF44336);
      case MoodLevel.anxious:
        return const Color(0xFF9C27B0);
      case MoodLevel.stressed:
        return const Color(0xFFE91E63);
    }
  }

  static MoodLevel fromSentiment(double score) {
    if (score >= 0.6) return MoodLevel.veryHappy;
    if (score >= 0.2) return MoodLevel.happy;
    if (score >= -0.2) return MoodLevel.neutral;
    if (score >= -0.6) return MoodLevel.sad;
    return MoodLevel.verySad;
  }
}

extension MoodSourceExtension on MoodSource {
  String get label {
    switch (this) {
      case MoodSource.manual:
        return 'Manual Entry';
      case MoodSource.character:
        return 'Character Chat';
      case MoodSource.games:
        return 'Games';
      case MoodSource.mindfulness:
        return 'Mindfulness';
      case MoodSource.academics:
        return 'Academics';
      case MoodSource.voice:
        return 'Voice Note';
    }
  }

  IconData get icon {
    switch (this) {
      case MoodSource.manual:
        return Icons.edit_outlined;
      case MoodSource.character:
        return Icons.chat_bubble_outline;
      case MoodSource.games:
        return Icons.videogame_asset_outlined;
      case MoodSource.mindfulness:
        return Icons.self_improvement;
      case MoodSource.academics:
        return Icons.school_outlined;
      case MoodSource.voice:
        return Icons.mic;
    }
  }
}

class WeeklyMoodReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double averageSentiment;
  final MoodTrend trend;
  final Map<MoodSource, int> sourceBreakdown;
  final List<String> insights;
  final int concernCount;

  WeeklyMoodReport({
    required this.weekStart,
    required this.weekEnd,
    required this.averageSentiment,
    required this.trend,
    required this.sourceBreakdown,
    required this.insights,
    required this.concernCount,
  });
}

enum MoodTrend {
  improving,
  stable,
  declining,
}

extension MoodTrendExtension on MoodTrend {
  String get label {
    switch (this) {
      case MoodTrend.improving:
        return 'Improving';
      case MoodTrend.stable:
        return 'Stable';
      case MoodTrend.declining:
        return 'Declining';
    }
  }

  String get emoji {
    switch (this) {
      case MoodTrend.improving:
        return '📈';
      case MoodTrend.stable:
        return '➡️';
      case MoodTrend.declining:
        return '📉';
    }
  }

  Color get color {
    switch (this) {
      case MoodTrend.improving:
        return const Color(0xFF4CAF50);
      case MoodTrend.stable:
        return const Color(0xFF2196F3);
      case MoodTrend.declining:
        return const Color(0xFFF44336);
    }
  }
}
