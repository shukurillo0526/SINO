/// SINO - Quiz Service
/// 
/// This service manages quiz content for the Study Drill and Peer Clash
/// game modes. It loads questions from localized JSON assets and provides
/// randomized question sets.
/// 
/// ## Features
/// - Multi-language support (English/Korean)
/// - Lazy loading of question assets
/// - Randomized question ordering
/// - Configurable question count per mode
/// 
/// ## Usage
/// ```dart
/// final quizService = QuizService();
/// 
/// // Full quiz (30 questions)
/// final studyQuestions = await quizService.getStudyDrillQuestions(true);
/// 
/// // Quick quiz (10 questions)
/// final clashQuestions = await quizService.getPeerClashQuestions(true);
/// ```
/// 
/// ## Question Format (JSON)
/// ```json
/// {
///   "question": "What is 2 + 2?",
///   "options": ["3", "4", "5", "6"],
///   "correctIndex": 1
/// }
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

// ============================================================
// QUESTION MODEL
// ============================================================

/// A quiz question with multiple choice options.
/// 
/// Each question has:
/// - A text prompt
/// - 4 answer options (typically)
/// - An index indicating the correct answer (0-based)
class Question {
  /// The question text to display.
  final String text;
  
  /// List of answer options.
  final List<String> options;
  
  /// Index of the correct answer in [options] (0-based).
  final int correctIndex;

  /// Creates a new [Question].
  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  /// Creates a [Question] from JSON data.
  /// 
  /// Expected format:
  /// ```json
  /// {
  ///   "question": "...",
  ///   "options": ["A", "B", "C", "D"],
  ///   "correctIndex": 0
  /// }
  /// ```
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }

  /// Converts this question to a JSON map.
  Map<String, dynamic> toJson() => {
    'question': text,
    'options': options,
    'correctIndex': correctIndex,
  };

  /// Checks if the given answer index is correct.
  bool isCorrect(int answerIndex) => answerIndex == correctIndex;
}

// ============================================================
// QUIZ SERVICE
// ============================================================

/// Service for loading and managing quiz questions.
/// 
/// Questions are loaded lazily from bundled JSON assets on first access.
/// The service caches loaded questions to avoid repeated file reads.
class QuizService {
  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// Cached English questions.
  List<Question>? _englishQuestions;
  
  /// Cached Korean questions.
  List<Question>? _koreanQuestions;

  /// Random number generator for shuffling.
  final Random _random = Random();

  // ============================================================
  // ASSET PATHS
  // ============================================================
  
  /// Path to English questions JSON.
  static const String _englishAssetPath = 'lib/assets/questions_en.json';
  
  /// Path to Korean questions JSON.
  static const String _koreanAssetPath = 'lib/assets/questions_ko.json';

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  /// Gets questions for Study Drill mode.
  /// 
  /// Returns all 30 questions in randomized order.
  /// Study Drill is a comprehensive review mode.
  /// 
  /// [isEnglish] Whether to return English (true) or Korean (false).
  /// 
  /// Returns a [Future] that resolves to a shuffled list of questions.
  Future<List<Question>> getStudyDrillQuestions(bool isEnglish) async {
    await _loadQuestions();
    
    final questions = isEnglish ? _englishQuestions! : _koreanQuestions!;
    return _shuffle(questions);
  }

  /// Gets questions for Peer Clash mode.
  /// 
  /// Returns 10 random questions for quick competitive play.
  /// Peer Clash is a fast-paced multiplayer mode.
  /// 
  /// [isEnglish] Whether to return English (true) or Korean (false).
  /// 
  /// Returns a [Future] that resolves to 10 random questions.
  Future<List<Question>> getPeerClashQuestions(bool isEnglish) async {
    await _loadQuestions();
    
    final questions = isEnglish ? _englishQuestions! : _koreanQuestions!;
    final shuffled = _shuffle(questions);
    return shuffled.take(10).toList();
  }

  /// Gets a specific number of random questions.
  /// 
  /// [isEnglish] Whether to return English (true) or Korean (false).
  /// [count] Number of questions to return.
  /// 
  /// Returns a [Future] that resolves to [count] random questions.
  Future<List<Question>> getRandomQuestions(bool isEnglish, int count) async {
    await _loadQuestions();
    
    final questions = isEnglish ? _englishQuestions! : _koreanQuestions!;
    final shuffled = _shuffle(questions);
    return shuffled.take(count).toList();
  }

  /// Gets the total number of available questions.
  /// 
  /// Useful for displaying progress (e.g., "Question 5 of 30").
  Future<int> getTotalQuestionCount(bool isEnglish) async {
    await _loadQuestions();
    
    final questions = isEnglish ? _englishQuestions! : _koreanQuestions!;
    return questions.length;
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  /// Loads questions from bundled JSON assets.
  /// 
  /// Questions are cached after first load.
  Future<void> _loadQuestions() async {
    // Load English questions if not cached
    if (_englishQuestions == null) {
      final String enData = await rootBundle.loadString(_englishAssetPath);
      final List<dynamic> enJson = jsonDecode(enData);
      _englishQuestions = enJson.map((q) => Question.fromJson(q)).toList();
    }

    // Load Korean questions if not cached
    if (_koreanQuestions == null) {
      final String koData = await rootBundle.loadString(_koreanAssetPath);
      final List<dynamic> koJson = jsonDecode(koData);
      _koreanQuestions = koJson.map((q) => Question.fromJson(q)).toList();
    }
  }

  /// Creates a shuffled copy of the question list.
  /// 
  /// Returns a new list; does not modify the original.
  List<Question> _shuffle(List<Question> questions) {
    final shuffled = List<Question>.from(questions);
    shuffled.shuffle(_random);
    return shuffled;
  }

  /// Clears the cached questions.
  /// 
  /// Forces a reload from assets on next access.
  /// Useful for testing or hot reload scenarios.
  void clearCache() {
    _englishQuestions = null;
    _koreanQuestions = null;
  }
}
