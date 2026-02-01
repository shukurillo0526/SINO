/// SINO - Conversation Memory Service
/// 
/// This service manages short-term conversation memory for the SINO AI
/// companion. It stores context about recent interactions to make
/// conversations feel continuous and personalized.
/// 
/// ## Features
/// - Short-term memory storage (last 20 items)
/// - Categorized memory types (stressors, achievements, etc.)
/// - Local persistence via SharedPreferences
/// - Context injection for AI prompts
/// 
/// ## Usage
/// ```dart
/// final service = ConversationService();
/// 
/// // Add a memory
/// await service.addMemory(
///   topic: 'Exams',
///   summary: 'User mentioned upcoming math exam',
///   type: MemoryType.stressor,
/// );
/// 
/// // Get context for AI
/// final context = service.getContextSummary(maxItems: 3);
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ============================================================
// CONVERSATION SERVICE
// ============================================================

/// Service for managing conversation memory and context.
/// 
/// This service maintains a bounded list of recent conversation topics,
/// stressors, and achievements to provide context for AI interactions.
/// 
/// Memory is persisted locally and synchronized when the user logs in.
class ConversationService with ChangeNotifier {
  // ============================================================
  // CONSTANTS
  // ============================================================
  
  /// Maximum number of memory items to retain.
  /// Older items are discarded when this limit is exceeded.
  static const int _maxMemoryItems = 20;
  
  /// Key used for local storage persistence.
  static const String _localStorageKey = 'sino_conversation_memory';

  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// Internal list of conversation memories.
  List<ConversationMemory> _memories = [];
  
  /// Public read-only access to memories.
  List<ConversationMemory> get memories => List.unmodifiable(_memories);

  // Note: Supabase integration can be added here when cloud sync is needed
  // bool get _isGuest => Supabase.instance.client.auth.currentUser == null;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  
  /// Creates a new [ConversationService] and loads persisted memories.
  ConversationService() {
    _loadMemories();
  }

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  /// Adds a new memory item to the conversation context.
  /// 
  /// [topic] Short label for the memory (e.g., "Exam", "Friends").
  /// [summary] Brief description of what was discussed.
  /// [type] Category of memory (defaults to [MemoryType.conversation]).
  /// [emotionalWeight] Optional sentiment weight (-1.0 to 1.0).
  /// 
  /// Example:
  /// ```dart
  /// await service.addMemory(
  ///   topic: 'Math Exam',
  ///   summary: 'User is worried about calculus test tomorrow',
  ///   type: MemoryType.stressor,
  ///   emotionalWeight: -0.6,
  /// );
  /// ```
  Future<void> addMemory({
    required String topic,
    required String summary,
    MemoryType type = MemoryType.conversation,
    double? emotionalWeight,
    String? companionId,
  }) async {
    final memory = ConversationMemory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic,
      summary: summary,
      type: type,
      emotionalWeight: emotionalWeight ?? 0.0,
      timestamp: DateTime.now(),
      companionId: companionId,
    );
    
    // Insert at beginning (most recent first)
    _memories.insert(0, memory);
    
    // Enforce memory limit
    if (_memories.length > _maxMemoryItems) {
      _memories = _memories.sublist(0, _maxMemoryItems);
    }
    
    await _saveMemories();
    notifyListeners();
  }

  /// Gets recent context formatted for AI prompt injection.
  /// 
  /// Returns a string summary of recent memories that can be
  /// prepended to user messages to provide context to the AI.
  /// 
  /// [maxItems] Maximum number of memories to include.
  /// 
  /// Example output:
  /// ```
  /// Recent context about this user:
  /// - [2m ago] Exam: Worried about calculus test
  /// - [1h ago] Friends: Had argument with roommate
  /// ```
  String getContextSummary({int maxItems = 5, String? companionId}) {
    if (_memories.isEmpty) return '';
    
    var filteredMemories = _memories;
    if (companionId != null) {
      filteredMemories = _memories.where((m) => m.companionId == companionId || m.companionId == null).toList();
    }
    
    final recentMemories = filteredMemories.take(maxItems);
    final buffer = StringBuffer();
    buffer.writeln('Recent context about this user:');
    
    for (var memory in recentMemories) {
      final age = DateTime.now().difference(memory.timestamp);
      final timeAgo = _formatTimeAgo(age);
      buffer.writeln('- [$timeAgo] ${memory.topic}: ${memory.summary}');
    }
    
    return buffer.toString();
  }

  /// Gets memories filtered by type.
  /// 
  /// Useful for proactive interventions based on recent stressors
  /// or achievements.
  /// 
  /// [type] The type of memories to retrieve.
  List<ConversationMemory> getMemoriesByType(MemoryType type) {
    return _memories.where((m) => m.type == type).toList();
  }

  /// Clears all conversation memory.
  /// 
  /// Use this when:
  /// - User logs out
  /// - User requests data deletion
  /// - Starting a fresh session
  Future<void> clearMemories() async {
    _memories.clear();
    await _saveMemories();
    notifyListeners();
    debugPrint('🦊 Conversation memory cleared');
  }

  // ============================================================
  // PERSISTENCE
  // ============================================================

  /// Loads memories from local storage.
  Future<void> _loadMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_localStorageKey);
      
      if (json != null) {
        final List<dynamic> decoded = jsonDecode(json);
        _memories = decoded
            .map((e) => ConversationMemory.fromJson(e))
            .toList();
        debugPrint('🦊 Loaded ${_memories.length} conversation memories');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading conversation memories: $e');
    }
  }

  /// Saves memories to local storage.
  Future<void> _saveMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_memories.map((m) => m.toJson()).toList());
      await prefs.setString(_localStorageKey, json);
    } catch (e) {
      debugPrint('❌ Error saving conversation memories: $e');
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// Formats a duration into a human-readable time ago string.
  String _formatTimeAgo(Duration age) {
    if (age.inMinutes < 1) {
      return 'now';
    } else if (age.inHours < 1) {
      return '${age.inMinutes}m ago';
    } else if (age.inDays < 1) {
      return '${age.inHours}h ago';
    } else {
      return '${age.inDays}d ago';
    }
  }
}

// ============================================================
// MEMORY TYPE ENUM
// ============================================================

/// Categories of conversation memory items.
enum MemoryType {
  /// General conversation topics.
  conversation,
  
  /// Academic or life stressors mentioned by user.
  stressor,
  
  /// Positive accomplishments or good news.
  achievement,
  
  /// User preferences learned from conversation.
  /// Example: "prefers breathing exercises over journaling"
  preference,
  
  /// Crisis-related context (handled with extra care).
  crisis,
}

// ============================================================
// CONVERSATION MEMORY MODEL
// ============================================================

/// A single memory item from a conversation.
/// 
/// Memory items capture context about what the user discussed
/// and can be used to make future conversations more personalized.
class ConversationMemory {
  /// Unique identifier for this memory.
  final String id;
  
  /// ID of the companion this memory is associated with.
  final String? companionId;
  
  /// Short label for the topic (e.g., "Exam", "Friends").
  final String topic;
  
  /// Brief summary of what was discussed.
  final String summary;
  
  /// Category of this memory.
  final MemoryType type;
  
  /// Emotional weight from -1.0 (negative) to 1.0 (positive).
  /// Neutral topics have weight 0.0.
  final double emotionalWeight;
  
  /// When this memory was recorded.
  final DateTime timestamp;

  /// Creates a new [ConversationMemory].
  ConversationMemory({
    required this.id,
    required this.topic,
    required this.summary,
    required this.type,
    required this.emotionalWeight,
    required this.timestamp,
    this.companionId,
  });

  /// Converts this memory to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'summary': summary,
    'type': type.index,
    'emotionalWeight': emotionalWeight,
    'timestamp': timestamp.toIso8601String(),
    'companionId': companionId,
  };

  /// Creates a [ConversationMemory] from a JSON map.
  factory ConversationMemory.fromJson(Map<String, dynamic> json) {
    return ConversationMemory(
      id: json['id'] as String,
      topic: json['topic'] as String,
      summary: json['summary'] as String,
      type: MemoryType.values[json['type'] as int? ?? 0],
      emotionalWeight: (json['emotionalWeight'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      companionId: json['companionId'] as String?,
    );
  }
}
