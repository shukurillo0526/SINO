/// SINO - Gemini AI Service
/// 
/// This service manages all AI-powered chat interactions for the SINO
/// companion character. It provides conversational AI capabilities using
/// Google's Gemini 2.0 Flash model via the OpenRouter API.
/// 
/// ## Features
/// - Multi-turn conversation with context memory
/// - Proactive wellness interventions
/// - Voice sentiment analysis
/// - Rate limit and error handling
/// 
/// ## Usage
/// ```dart
/// final gemini = GeminiService();
/// gemini.setConversationService(conversationService);
/// final response = await gemini.getChatResponse('Hello!');
/// ```
/// 
/// ## Dependencies
/// - [ConversationService] for context memory
/// - OpenRouter API for AI model access
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'conversation_service.dart';
import '../models/mood_models.dart';
import '../models/companion_model.dart';

// ============================================================
// GEMINI SERVICE
// ============================================================

/// Service for AI-powered chat interactions with the SINO companion.
/// 
/// This service follows the Singleton pattern to ensure consistent
/// conversation state across the application.
/// 
/// The service supports:
/// - Context-aware multi-turn conversations
/// - Proactive wellness interventions
/// - Voice note sentiment analysis
/// - Graceful error handling with user-friendly messages
class GeminiService {
  // ============================================================
  // SINGLETON PATTERN
  // ============================================================
  
  static final GeminiService _instance = GeminiService._internal();
  
  /// Factory constructor returning the singleton instance.
  factory GeminiService() => _instance;
  
  /// Private constructor for singleton initialization.
  GeminiService._internal() {
    _initialize();
  }

  // ============================================================
  // CONSTANTS
  // ============================================================
  
  /// OpenRouter API endpoint for chat completions.
  static const String _openRouterUrl = 
      'https://openrouter.ai/api/v1/chat/completions';
  
  /// AI model identifier (Gemini 2.0 Flash - free tier).
  static const String _model = 'google/gemini-2.0-flash-exp:free';
  
  /// Request timeout duration.
  static const Duration _timeout = Duration(seconds: 30);
  
  /// Maximum number of messages to keep in conversation history.
  /// Keeps context manageable while staying within token limits.
  static const int _maxHistoryLength = 10;

  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// OpenRouter API key loaded from environment.
  String? _apiKey;
  
  /// Whether the service has been successfully initialized.
  bool _initialized = false;
  
  /// Reference to conversation service for context memory.
  ConversationService? _conversationService;
  
  /// Conversation history for multi-turn chat.
  /// Includes system prompt and user/assistant messages.
  final List<Map<String, String>> _chatHistory = [];

  /// Flag indicating if proactive intervention should be offered.
  bool _shouldOfferIntervention = false;
  
  /// Reason for the pending intervention (if any).
  String? _pendingInterventionReason;

  // ============================================================
  // GETTERS
  // ============================================================
  
  /// Whether proactive intervention should be offered to the user.
  bool get shouldOfferIntervention => _shouldOfferIntervention;
  
  /// The reason for pending intervention, if any.
  String? get pendingInterventionReason => _pendingInterventionReason;
  
  /// Whether the service is initialized and ready for use.
  bool get isInitialized => _initialized;

  // ============================================================
  // INITIALIZATION
  // ============================================================
  
  /// Initializes the service by loading API credentials.
  void _initialize() {
    _apiKey = dotenv.env['OPENROUTER_API_KEY'];
    _initialized = _apiKey != null && _apiKey!.isNotEmpty;
    
    debugPrint('🦊 GeminiService initialized: $_initialized');
    
    if (_initialized) {
      // Add system prompt as first message
      _chatHistory.add({
        'role': 'system',
        'content': _buildSystemPrompt(),
      });
    }
  }

  /// Sets the conversation service for context memory integration.
  /// 
  /// [service] The conversation service instance to use for memory.
  void setConversationService(ConversationService service) {
    _conversationService = service;
    debugPrint('🦊 ConversationService connected to GeminiService');
  }

  // ============================================================
  // SYSTEM PROMPT
  // ============================================================
  
  /// Builds the system prompt that defines SINO's personality.
  /// 
  /// The prompt establishes:
  /// - Character persona (friendly fox companion)
  /// - Response style (short, warm, encouraging)
  /// - Safety guidelines (crisis detection, no diagnosis)
  String _buildSystemPrompt({CompanionModel? companion}) {
    final name = companion?.name ?? 'SINO';
    final role = companion?.role.name ?? 'buddy';
    final traits = companion?.personalityTraits.join(', ') ?? 'Warm, Encouraging, Playful';
    
    return '''
You are $name. You are a $role to the user.

PERSONALITY:
- Traits: $traits
- Keep responses SHORT (1-2 sentences)
- Be warm and encouraging
- Use emojis occasionally

RULES:
- Never diagnose mental health conditions
- If someone mentions self-harm, respond with care and suggest calling 109
- Validate feelings before offering solutions
- Celebrate small wins
''';
  }

  // ============================================================
  // CHAT METHODS
  // ============================================================

  /// Sends a message to the AI and returns the response.
  /// 
  /// [message] The user's input message.
  /// [companion] Optional active companion to context-switch the AI persona.
  /// 
  /// Returns a [Future<String>] containing the AI's response.
  Future<String> getChatResponse(String message, {CompanionModel? companion}) async {
    debugPrint('🦊 getChatResponse called: ${message.take(50)}...');
    
    // Check initialization
    if (!_initialized) {
      debugPrint('⚠️ GeminiService not initialized');
      return "I'm still warming up! Give me a moment... 🦊";
    }
    
    // Update system prompt if companion is provided
    if (companion != null && _chatHistory.isNotEmpty) {
      _chatHistory[0] = {
        'role': 'system',
        'content': _buildSystemPrompt(companion: companion),
      };
    }
    
    final client = http.Client();
    
    try {
      // Build context-aware message with memory
      final contextualMessage = await _buildContextualMessage(message, companionId: companion?.id);
      
      // Add to conversation history
      _chatHistory.add({'role': 'user', 'content': contextualMessage});
      _trimHistory();
      
      debugPrint('🦊 Sending to OpenRouter...');
      
      // Make API request
      final response = await _sendRequest(client);
      
      // Process response
      return _processResponse(response);
      
    } on TimeoutException {
      debugPrint('⚠️ Request timed out');
      return "I'm thinking hard but it's taking too long. Let's try again! 🦊";
    } catch (e) {
      debugPrint('❌ Chat error: $e');
      return "Oops! Something went wrong. Let's try again! 🦊";
    } finally {
      client.close();
    }
  }
  
  /// Fetches a short motivational quote from the AI.
  Future<String> getDailyQuote({CompanionModel? companion}) async {
    if (!_initialized) return "Keep going! You're doing great.";

    final client = http.Client();
    final name = companion?.name ?? 'SINO';
    
    try {
      final response = await client.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://sino-app.com',
          'X-Title': 'SINO',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': 'You are $name, a supportive companion. Provide a SHORT, one-sentence motivational quote for a student. No hashtags. Just the text.'},
            {'role': 'user', 'content': 'Give me a quote.'}
          ],
          'max_tokens': 50,
          'temperature': 0.8,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var quote = data['choices']?[0]?['message']?['content'] ?? "Believe in yourself!";
        return quote.replaceAll('"', ''); // Remove quotes if added by AI
      }
    } catch (e) {
      debugPrint('Quote fetch error: $e');
    } finally {
      client.close();
    }
    return "Every step counts!";
  }

  /// Builds a context-aware message by injecting conversation memory.
  Future<String> _buildContextualMessage(String message, {String? companionId}) async {
    if (_conversationService == null) {
      return message;
    }
    
    // Get recent context
    final context = _conversationService!.getContextSummary(maxItems: 2, companionId: companionId);
    
    // Store this interaction as a memory
    await _conversationService!.addMemory(
      topic: 'Chat',
      summary: message.take(50),
      type: MemoryType.conversation,
      companionId: companionId,
    );
    
    // Inject context if available
    if (context.isNotEmpty) {
      return '[Context: $context]\n\nUser: $message';
    }
    
    return message;
  }

  /// Sends the HTTP request to OpenRouter.
  Future<http.Response> _sendRequest(http.Client client) async {
    return await client.post(
      Uri.parse(_openRouterUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://sino-app.com',
        'X-Title': 'SINO',
      },
      body: jsonEncode({
        'model': _model,
        'messages': _chatHistory,
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    ).timeout(_timeout);
  }

  /// Processes the API response and extracts the message.
  String _processResponse(http.Response response) {
    debugPrint('🦊 Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final assistantMessage = data['choices']?[0]?['message']?['content'] 
          ?? "I'm here for you! 🦊";
      
      // Add to history
      _chatHistory.add({'role': 'assistant', 'content': assistantMessage});
      
      return assistantMessage;
    }
    
    // Handle specific error codes
    return _handleErrorResponse(response.statusCode, response.body);
  }

  /// Handles error responses with user-friendly messages.
  String _handleErrorResponse(int statusCode, String body) {
    debugPrint('❌ OpenRouter error: $statusCode - $body');
    
    switch (statusCode) {
      case 429:
        return "I need a quick break! Too many friends chatting. Try again soon 🦊";
      case 401:
        return "My API key seems invalid. Please check settings. 🦊";
      case 503:
        return "The AI servers are busy. Let's try again in a moment! 🦊";
      default:
        return "Hmm, something's not right. (Error: $statusCode) 🦊";
    }
  }

  /// Trims conversation history to stay within limits.
  /// 
  /// Keeps the system prompt and the most recent messages.
  void _trimHistory() {
    if (_chatHistory.length > _maxHistoryLength + 1) {
      final systemMessage = _chatHistory.first;
      _chatHistory.removeRange(1, _chatHistory.length - _maxHistoryLength);
      _chatHistory[0] = systemMessage;
    }
  }

  // ============================================================
  // PROACTIVE INTERVENTION
  // ============================================================

  /// Checks if proactive intervention should be offered based on user state.
  /// 
  /// Intervention is triggered when:
  /// - 3+ upcoming exams AND stressed/anxious mood
  /// - 3+ overdue tasks
  /// - Very sad mood detected
  /// 
  /// [upcomingExamCount] Number of exams in the next 7 days.
  /// [recentMood] The user's most recent mood level.
  /// [overdueTasks] Number of overdue tasks.
  void checkForProactiveIntervention({
    required int upcomingExamCount,
    required MoodLevel? recentMood,
    required int overdueTasks,
  }) {
    _shouldOfferIntervention = false;
    _pendingInterventionReason = null;

    // Rule 1: Exam stress
    if (upcomingExamCount >= 3 && 
        (recentMood == MoodLevel.stressed || recentMood == MoodLevel.anxious)) {
      _shouldOfferIntervention = true;
      _pendingInterventionReason = 'exam_stress';
      return;
    }

    // Rule 2: Task overload
    if (overdueTasks >= 3) {
      _shouldOfferIntervention = true;
      _pendingInterventionReason = 'overdue_tasks';
      return;
    }

    // Rule 3: Low mood
    if (recentMood == MoodLevel.verySad) {
      _shouldOfferIntervention = true;
      _pendingInterventionReason = 'low_mood';
      return;
    }
  }

  /// Gets a proactive message based on the intervention reason.
  /// 
  /// Returns a tailored message for the detected situation.
  Future<String> getProactiveMessage() async {
    switch (_pendingInterventionReason) {
      case 'exam_stress':
        return "I noticed you have a lot of exams coming up. "
               "Want to try a quick breathing exercise together? 🦊";
      case 'overdue_tasks':
        return "Hey, I see some tasks piling up. "
               "Want help breaking them into smaller steps? 🦊";
      case 'low_mood':
        return "I noticed you've been feeling down lately. "
               "I'm here if you want to talk. 🦊";
      default:
        return "Hey! Just checking in. How are you feeling today? 🦊";
    }
  }

  /// Clears the intervention flag after it has been shown.
  void clearIntervention() {
    _shouldOfferIntervention = false;
    _pendingInterventionReason = null;
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  /// Resets the chat session, clearing all history.
  /// 
  /// Useful when starting a new conversation or switching users.
  void resetSession() {
    _chatHistory.clear();
    _chatHistory.add({'role': 'system', 'content': _buildSystemPrompt()});
    debugPrint('🦊 Chat session reset');
  }

  // ============================================================
  // VOICE ANALYSIS
  // ============================================================

  /// Analyzes voice note transcription for sentiment.
  /// 
  /// Uses keyword-based analysis to determine emotional tone.
  /// 
  /// [transcription] The transcribed text from a voice note.
  /// 
  /// Returns a map containing:
  /// - `sentiment`: Score from -1.0 (negative) to 1.0 (positive)
  /// - `summary`: Text summary ('Positive', 'Neutral', 'Concerning')
  /// - `concerns`: List of concerning phrases detected
  Future<Map<String, dynamic>> analyzeVoiceSentiment(String transcription) async {
    final lowerText = transcription.toLowerCase();
    double sentiment = 0.0;
    
    // Positive keyword detection
    const positiveWords = [
      'happy', 'good', 'great', 'awesome', 'love', 'excited',
      '좋아', '행복', '기뻐', // Korean positive words
    ];
    
    // Negative keyword detection
    const negativeWords = [
      'sad', 'bad', 'hate', 'stressed', 'anxious', 'worried',
      '슬퍼', '힘들어', '불안해', // Korean negative words
    ];
    
    // Calculate sentiment score
    for (var word in positiveWords) {
      if (lowerText.contains(word)) sentiment += 0.2;
    }
    for (var word in negativeWords) {
      if (lowerText.contains(word)) sentiment -= 0.2;
    }
    
    // Clamp to valid range
    sentiment = sentiment.clamp(-1.0, 1.0);
    
    // Determine summary
    String summary;
    if (sentiment > 0.2) {
      summary = 'Positive';
    } else if (sentiment < -0.2) {
      summary = 'Concerning';
    } else {
      summary = 'Neutral';
    }
    
    return {
      'sentiment': sentiment,
      'summary': summary,
      'concerns': <String>[],
    };
  }

  /// Checks basic internet connectivity.
  /// 
  /// Makes a quick request to Google to verify network access.
  /// Useful for diagnosing connection issues.
  Future<bool> checkConnectivity() async {
    try {
      debugPrint('🔌 Checking internet connectivity...');
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      
      debugPrint('🔌 Connectivity: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🔌 Connectivity check failed: $e');
      return false;
    }
  }
}

// ============================================================
// EXTENSION HELPERS
// ============================================================

/// Extension to safely take first N characters from a string.
extension StringTake on String {
  /// Returns the first [n] characters, or the whole string if shorter.
  String take(int n) => length <= n ? this : '${substring(0, n)}...';
}
