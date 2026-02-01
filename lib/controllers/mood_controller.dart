/// SINO - Mood Controller
/// 
/// This controller manages state for mood tracking, including:
/// - Mood entry CRUD operations
/// - Cloud sync with Supabase
/// - Local persistence for guest users
/// - Crisis alert logging
/// - Analytics and weekly reports
/// 
/// ## Usage
/// ```dart
/// final moodController = context.read<MoodController>();
/// await moodController.addManualMood(MoodLevel.happy);
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import '../models/mood_models.dart';
import '../services/crisis_service.dart';
import '../services/supabase_data_service.dart';

// ============================================================
// MOOD CONTROLLER
// ============================================================

/// Controller for mood tracking state management.
/// 
/// Supports complex analytic queries like weekly reports and
/// source breakdowns. Switches storage strategy based on
/// authentication state (Cloud vs Local).
class MoodController with ChangeNotifier {
  // ============================================================
  // CONSTANTS
  // ============================================================
  
  static const String _localStorageKey = 'mood_entries_v2';

  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// In-memory list of mood entries.
  List<MoodEntry> _entries = [];
  
  /// History of crisis alerts triggered during this session.
  final List<Map<String, dynamic>> _crisisAlerts = [];
  
  /// Service for cloud data persistence.
  final SupabaseDataService _dataService = SupabaseDataService();
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  /// All mood entries, unordered.
  List<MoodEntry> get entries => List.unmodifiable(_entries);
  
  /// Most recent 20 entries for dashboard display.
  List<MoodEntry> get recentEntries => 
      _entries.reversed.take(20).toList();
  
  /// History of crisis alerts.
  List<Map<String, dynamic>> get crisisAlerts => 
      List.unmodifiable(_crisisAlerts);

  /// The most recent mood entry, or null if empty.
  MoodEntry? get latestEntry => 
      _entries.isEmpty ? null : _entries.last;

  /// Whether current user is a guest (not authenticated).
  bool get _isGuest => Supabase.instance.client.auth.currentUser == null;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  
  MoodController() {
    _loadEntries();
  }

  // ============================================================
  // MOOD ENTRY ACTIONS
  // ============================================================

  /// Adds a manually logged mood entry (e.g., from mood picker).
  Future<void> addManualMood(MoodLevel mood, {String? context}) async {
    final entry = MoodEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      mood: mood,
      source: MoodSource.manual,
      sentimentScore: _moodToSentiment(mood),
      context: context,
    );
    
    await _addEntry(entry);
  }

  /// Adds a voice-based mood entry.
  Future<void> addVoiceMood(
    MoodLevel mood, {
    String? context,
    String? audioPath,
  }) async {
    final entry = MoodEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      mood: mood,
      source: MoodSource.voice,
      sentimentScore: _moodToSentiment(mood),
      context: context,
      metadata: audioPath != null ? {'audioPath': audioPath} : null,
    );
    
    await _addEntry(entry);
  }

  /// Adds a mood entry from an external service (chat, games, etc.).
  Future<void> addMoodFromService(
    MoodSource source,
    double sentimentScore, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    final mood = MoodLevelExtension.fromSentiment(sentimentScore);
    
    final entry = MoodEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      mood: mood,
      source: source,
      sentimentScore: sentimentScore.clamp(-1.0, 1.0),
      context: context,
      metadata: metadata,
    );
    
    await _addEntry(entry);
  }

  /// Logs a crisis alert and creates a corresponding mood entry.
  /// 
  /// This ensures crisis events are tracked in mood history for reports.
  Future<void> addCrisisAlert(RiskLevel level, String context) async {
    final alert = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.index,
      'context': context,
    };
    _crisisAlerts.add(alert);
    
    // Auto-log as a negative mood entry
    await addMoodFromService(
      MoodSource.character,
      level == RiskLevel.high ? -1.0 : -0.7,
      context: 'CRISIS ALERT: $context',
      metadata: {
        'isCrisis': true,
        'riskLevel': level.index
      },
    );
    
    notifyListeners();
  }

  // ============================================================
  // INTERNAL HELPERS
  // ============================================================

  /// Internal method to add entry and handle persistence.
  Future<void> _addEntry(MoodEntry entry) async {
    _entries.add(entry);
    notifyListeners();

    try {
      if (_isGuest) {
        await _saveEntriesLocal();
      } else {
        await _dataService.addMoodEntry(entry);
      }
    } catch (e) {
      debugPrint('❌ Error persisting mood entry: $e');
    }
  }

  /// Map structured mood levels to sentiment scores.
  double _moodToSentiment(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.veryHappy: return 0.8;
      case MoodLevel.happy: return 0.5;
      case MoodLevel.neutral: return 0.0;
      case MoodLevel.sad: return -0.4;
      case MoodLevel.verySad: return -0.8;
      case MoodLevel.anxious: return -0.5;
      case MoodLevel.stressed: return -0.6;
    }
  }

  /// Generates a unique ID for local entries.
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // ============================================================
  // PERSISTENCE
  // ============================================================
  
  /// Loads entries from appropriate storage source.
  Future<void> _loadEntries() async {
    if (_isGuest) {
      await _loadEntriesLocal();
    } else {
      await _loadEntriesCloud();
    }
    notifyListeners();
  }

  Future<void> _loadEntriesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_localStorageKey);
      
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _entries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
        debugPrint('📥 Loaded ${_entries.length} local mood entries');
      }
    } catch (e) {
      debugPrint('❌ Error loading local entries: $e');
    }
  }

  Future<void> _loadEntriesCloud() async {
    try {
      _entries = await _dataService.fetchMoodEntries();
      debugPrint('☁️ Loaded ${_entries.length} cloud mood entries');
    } catch (e) {
      debugPrint('❌ Error loading cloud entries: $e');
    }
  }

  Future<void> _saveEntriesLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString(_localStorageKey, jsonStr);
    } catch (e) {
      debugPrint('❌ Error saving local entries: $e');
    }
  }

  // ============================================================
  // ANALYTICS & REPORTS
  // ============================================================
  
  /// Generates a report for the current week.
  WeeklyMoodReport getWeeklyReport() {
    final now = DateTime.now();
    // Start of week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // Filter entries for this week
    final weekEntries = getEntriesForDateRange(
      weekStart, 
      weekEnd.add(const Duration(days: 1))
    );

    if (weekEntries.isEmpty) {
      return _createEmptyReport(weekStart, weekEnd);
    }

    // Calculations
    final avgSentiment = _calculateAverage(weekEntries);
    final trend = _calculateTrend(weekEntries);
    final sourceBreakdown = _calculateSourceBreakdown(weekEntries);
    final insights = _generateInsights(weekEntries, avgSentiment, sourceBreakdown);
    final concernCount = weekEntries
        .where((e) => e.sentimentScore < -0.3)
        .length;

    return WeeklyMoodReport(
      weekStart: weekStart,
      weekEnd: weekEnd,
      averageSentiment: avgSentiment,
      trend: trend,
      sourceBreakdown: sourceBreakdown,
      insights: insights,
      concernCount: concernCount,
    );
  }

  WeeklyMoodReport _createEmptyReport(DateTime start, DateTime end) {
    return WeeklyMoodReport(
      weekStart: start,
      weekEnd: end,
      averageSentiment: 0.0,
      trend: MoodTrend.stable,
      sourceBreakdown: {},
      insights: ['No mood data recorded this week.'],
      concernCount: 0,
    );
  }

  double _calculateAverage(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final sum = entries.fold<double>(0.0, (s, e) => s + e.sentimentScore);
    return sum / entries.length;
  }

  Map<MoodSource, int> _calculateSourceBreakdown(List<MoodEntry> entries) {
    final breakdown = <MoodSource, int>{};
    for (var entry in entries) {
      breakdown[entry.source] = (breakdown[entry.source] ?? 0) + 1;
    }
    return breakdown;
  }

  MoodTrend _calculateTrend(List<MoodEntry> entries) {
    if (entries.length < 2) return MoodTrend.stable;

    final midpoint = entries.length ~/ 2;
    final firstHalf = entries.sublist(0, midpoint);
    final secondHalf = entries.sublist(midpoint);

    final firstAvg = _calculateAverage(firstHalf);
    final secondAvg = _calculateAverage(secondHalf);
    final diff = secondAvg - firstAvg;

    if (diff > 0.15) return MoodTrend.improving;
    if (diff < -0.15) return MoodTrend.declining;
    return MoodTrend.stable;
  }

  Map<MoodSource, double> getAverageBySource() {
    final result = <MoodSource, double>{};
    
    for (var source in MoodSource.values) {
      final sourceEntries = _entries.where((e) => e.source == source).toList();
      if (sourceEntries.isNotEmpty) {
        result[source] = sourceEntries.fold<double>(
          0.0, (sum, e) => sum + e.sentimentScore
        ) / sourceEntries.length;
      }
    }
    
    return result;
  }

  List<String> _generateInsights(
    List<MoodEntry> entries,
    double avgSentiment,
    Map<MoodSource, int> sourceBreakdown,
  ) {
    final insights = <String>[];

    // Overall Insight
    if (avgSentiment > 0.3) {
      insights.add('Great week! Your mood has been mostly positive.');
    } else if (avgSentiment < -0.3) {
      insights.add('This week has been challenging. Consider talking to SINO.');
    } else {
      insights.add('Your mood has been fairly balanced this week.');
    }

    // Source Insight
    if (sourceBreakdown.isNotEmpty) {
      final topSource = sourceBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Most mood logs came from ${topSource.key.label}.');
    }

    // Stress Detection
    final academicEntries = entries
        .where((e) => e.source == MoodSource.academics)
        .toList();
        
    if (academicEntries.isNotEmpty) {
      final academicAvg = _calculateAverage(academicEntries);
      if (academicAvg < -0.2) {
        insights.add('Academic tasks seem stressful lately. Try breaking them down.');
      }
    }

    return insights;
  }

  /// Gets entries within a specific date range.
  List<MoodEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((e) =>
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();
  }

  /// Calculates average sentiment for a specific day.
  double getAverageSentimentForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final entries = getEntriesForDateRange(start, end);
    return _calculateAverage(entries);
  }

  // ============================================================
  // DEBUG / SAMPLE DATA
  // ============================================================
  
  /// Loads sample data for testing or demo purposes.
  Future<void> loadSampleData() async {
    final now = DateTime.now();
    
    _entries = [
      MoodEntry(
        id: 'sample_1',
        timestamp: now.subtract(const Duration(days: 1)),
        mood: MoodLevel.happy,
        source: MoodSource.character,
        sentimentScore: 0.5,
        context: 'Chatted with SINO',
      ),
      MoodEntry(
        id: 'sample_2',
        timestamp: now.subtract(const Duration(days: 2)),
        mood: MoodLevel.stressed,
        source: MoodSource.academics,
        sentimentScore: -0.6,
        context: 'Math homework',
      ),
      MoodEntry(
        id: 'sample_3',
        timestamp: now.subtract(const Duration(days: 3)),
        mood: MoodLevel.veryHappy,
        source: MoodSource.games,
        sentimentScore: 0.8,
        context: 'Won a game',
      ),
      // Add more samples to simulate a full week
      MoodEntry(
        id: 'sample_4',
        timestamp: now.subtract(const Duration(days: 4)),
        mood: MoodLevel.neutral,
        source: MoodSource.manual,
        sentimentScore: 0.0,
      ),
      MoodEntry(
        id: 'sample_5',
        timestamp: now.subtract(const Duration(days: 5)),
        mood: MoodLevel.anxious,
        source: MoodSource.voice,
        sentimentScore: -0.5,
        context: 'Worried about exams',
      ),
       MoodEntry(
        id: 'sample_6',
        timestamp: now.subtract(const Duration(days: 6)),
        mood: MoodLevel.happy,
        source: MoodSource.mindfulness,
        sentimentScore: 0.5,
        context: 'Completed breathing exercise',
      ),
        MoodEntry(
        id: 'sample_7',
        timestamp: now.subtract(const Duration(days: 0)),
        mood: MoodLevel.happy,
        source: MoodSource.manual,
        sentimentScore: 0.5,
      ),
    ];
    
    debugPrint('🧪 Loaded sample mood data');
    notifyListeners();
    
    // Persist if guest
    if (_isGuest) await _saveEntriesLocal();
  }
}
