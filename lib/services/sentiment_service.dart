/// SINO - Sentiment Analysis Service
/// 
/// This service provides rule-based sentiment analysis for text content.
/// It uses a keyword-matching approach with intensity modifiers to
/// calculate sentiment scores.
/// 
/// ## Features
/// - Keyword-based positive/negative detection
/// - Intensity modifier support (very, really, etc.)
/// - Performance-based sentiment mapping
/// - Predefined sentiment values for app actions
/// 
/// ## Usage
/// ```dart
/// final score = SentimentService.analyzeSentiment("I'm very happy!");
/// // Returns: ~0.3 (positive)
/// 
/// final perfScore = SentimentService.analyzePerformance(8, 10);
/// // Returns: 0.5 (good performance)
/// ```
/// 
/// ## Score Range
/// - **-1.0 to -0.4**: Negative (concerning)
/// - **-0.4 to 0.2**: Neutral
/// - **0.2 to 1.0**: Positive
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

// ============================================================
// SENTIMENT SERVICE
// ============================================================

/// Service for analyzing text sentiment using rule-based keyword matching.
/// 
/// All methods are static as this service maintains no state.
/// The analysis is lightweight and runs locally without API calls.
class SentimentService {
  // ============================================================
  // KEYWORD DICTIONARIES
  // ============================================================
  
  /// Words indicating positive sentiment.
  static const List<String> _positiveWords = [
    // English
    'happy', 'great', 'good', 'love', 'fun', 'excellent', 'wonderful',
    'amazing', 'awesome', 'fantastic', 'joy', 'excited', 'proud', 'confident',
    'relaxed', 'calm', 'peaceful', 'grateful', 'thankful', 'blessed',
    // Korean could be added here
  ];

  /// Words indicating negative sentiment.
  static const List<String> _negativeWords = [
    // English
    'sad', 'bad', 'hate', 'difficult', 'hard', 'terrible', 'awful',
    'horrible', 'worried', 'anxious', 'stressed', 'depressed', 'angry',
    'frustrated', 'upset', 'scared', 'afraid', 'lonely', 'tired', 'exhausted',
    // Korean could be added here
  ];

  /// Words that intensify the following sentiment word.
  static const List<String> _intensifiers = [
    'very', 'really', 'extremely', 'so', 'too', 'absolutely',
  ];

  // ============================================================
  // TEXT ANALYSIS
  // ============================================================

  /// Analyzes text and returns a sentiment score.
  /// 
  /// Scans the text for positive and negative keywords, applying
  /// intensity modifiers when detected.
  /// 
  /// [text] The text to analyze.
  /// 
  /// Returns a score from -1.0 (very negative) to 1.0 (very positive).
  /// Returns 0.0 for empty text.
  /// 
  /// Example:
  /// ```dart
  /// SentimentService.analyzeSentiment("I'm happy"); // ~0.2
  /// SentimentService.analyzeSentiment("I'm very happy"); // ~0.3
  /// SentimentService.analyzeSentiment("I'm sad and stressed"); // ~-0.4
  /// ```
  static double analyzeSentiment(String text) {
    if (text.trim().isEmpty) return 0.0;

    final lowerText = text.toLowerCase();
    final words = lowerText.split(RegExp(r'\s+'));
    
    double score = 0.0;
    double intensity = 1.0;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      
      // Check for intensifiers (affects next word)
      if (_intensifiers.contains(word)) {
        intensity = 1.5;
        continue;
      }

      // Check positive words
      if (_positiveWords.contains(word)) {
        score += (0.2 * intensity);
      }

      // Check negative words
      if (_negativeWords.contains(word)) {
        score -= (0.2 * intensity);
      }

      // Reset intensity after each word
      intensity = 1.0;
    }

    // Clamp to valid range
    return score.clamp(-1.0, 1.0);
  }

  // ============================================================
  // PERFORMANCE-BASED SENTIMENT
  // ============================================================

  /// Converts quiz/game performance to a sentiment score.
  /// 
  /// Maps the percentage of correct answers to a sentiment value
  /// that can be logged as a mood indicator.
  /// 
  /// [correct] Number of correct answers.
  /// [total] Total number of questions.
  /// 
  /// Returns:
  /// - 90%+: 0.8 (Excellent)
  /// - 70-89%: 0.5 (Good)
  /// - 50-69%: 0.0 (Okay)
  /// - 30-49%: -0.3 (Poor)
  /// - <30%: -0.6 (Very poor)
  static double analyzePerformance(int correct, int total) {
    if (total == 0) return 0.0;
    
    final percentage = correct / total;
    
    if (percentage >= 0.9) return 0.8;   // Excellent
    if (percentage >= 0.7) return 0.5;   // Good
    if (percentage >= 0.5) return 0.0;   // Okay
    if (percentage >= 0.3) return -0.3;  // Poor
    return -0.6;                         // Very poor
  }

  // ============================================================
  // PREDEFINED SENTIMENT VALUES
  // ============================================================

  /// Sentiment boost for completing a task.
  /// 
  /// Use this when logging mood from task completion.
  static double getTaskCompletionSentiment() => 0.4;

  /// Sentiment impact of having overdue tasks.
  /// 
  /// Use this when detecting stress from overdue items.
  static double getOverdueTaskSentiment() => -0.3;

  /// Sentiment boost from completing mindfulness activities.
  /// 
  /// Higher than task completion as mindfulness directly
  /// impacts emotional wellbeing.
  static double getMindfulnessSentiment() => 0.6;

  /// Sentiment boost for daily check-in.
  /// 
  /// Small positive reinforcement for engagement.
  static double getDailyCheckInSentiment() => 0.2;

  /// Sentiment boost for game completion.
  /// 
  /// Rewards engagement with games feature.
  static double getGameCompletionSentiment() => 0.3;
}
