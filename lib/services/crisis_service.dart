/// SINO - Crisis Detection Service
/// 
/// This service provides real-time crisis detection and intervention
/// capabilities for the SINO companion. It analyzes user text input
/// for indicators of distress and provides appropriate responses.
/// 
/// ## Features
/// - Weighted keyword detection (Korean and English)
/// - Three-tier risk assessment (Low/Medium/High)
/// - Culturally appropriate crisis responses
/// - Integration with crisis hotlines
/// 
/// ## Risk Levels
/// - **High**: Immediate crisis (suicide, self-harm mentions)
///   - Action: Connect to 109 crisis hotline
/// - **Medium**: Moderate distress (hopelessness, can't cope)
///   - Action: Warm handoff to counselor (1393)
/// - **Low**: Mild stress
///   - Action: Breathing exercise offer
/// 
/// ## Usage
/// ```dart
/// final risk = CrisisService.analyzeForCrisis(userMessage);
/// if (risk != null) {
///   final response = CrisisService.getSafetyInfo(risk, isEnglish);
///   // Show crisis dialog
/// }
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
// ENUMS & DATA CLASSES
// ============================================================

/// Risk level classification for crisis detection.
/// 
/// Each level triggers different intervention protocols.
enum RiskLevel {
  /// Mild distress - offer gentle support and coping tools.
  low,
  
  /// Moderate distress - warm handoff with human connection option.
  /// This is the "soft-crisis" tier for transitional support.
  medium,
  
  /// Severe distress - immediate crisis resources and hotline.
  high,
}

/// Action types for crisis response buttons.
enum CrisisAction {
  /// No action button displayed.
  none,
  
  /// Direct call to crisis hotline (109).
  callHotline,
  
  /// Soft escalation with counselor connection (1393).
  warmHandoff,
  
  /// Offer immediate coping tool (breathing exercise).
  breathingExercise,
}

/// Response object containing crisis intervention details.
class CrisisResponse {
  /// The supportive message to display.
  final String message;
  
  /// Optional label for action button.
  final String? actionLabel;
  
  /// Optional URL for action (tel: or https:).
  final String? actionUrl;
  
  /// Type of action this response triggers.
  final CrisisAction action;
  
  /// Creates a [CrisisResponse] with the given parameters.
  CrisisResponse(
    this.message, {
    this.actionLabel,
    this.actionUrl,
    this.action = CrisisAction.none,
  });
}

// ============================================================
// CRISIS SERVICE
// ============================================================

/// Service for detecting crisis indicators and providing interventions.
/// 
/// This service uses a weighted keyword system to detect varying levels
/// of user distress. All methods are static as the service maintains
/// no state.
/// 
/// ## Keyword Weights
/// - **10 points**: Self-harm/suicide keywords (immediate crisis)
/// - **5-6 points**: Intense distress keywords
/// - **2-4 points**: Mild stress indicators
/// 
/// ## Threshold Scores
/// - High risk: 10+ points
/// - Medium risk: 5-9 points
/// - Low risk: 1-4 points
class CrisisService {
  // ============================================================
  // KEYWORD DATABASE
  // ============================================================
  
  /// Weighted keywords for crisis detection.
  /// 
  /// Higher weights indicate more severe crisis indicators.
  /// Includes both English and Korean keywords for bilingual support.
  static const Map<String, int> _redFlagKeywords = {
    // === CRITICAL: Self-harm / Suicide (10 points) ===
    'hurt myself': 10,
    'end it all': 10,
    'don\'t want to live': 10,
    'suicide': 10,
    'kill myself': 10,
    'better off dead': 10,
    // Korean equivalents
    '자해': 10,           // Self-harm
    '자살': 10,           // Suicide
    '죽고 싶어': 10,      // Want to die
    '살고 싶지 않아': 10, // Don't want to live
    
    // === SEVERE: Intense distress (5-6 points) ===
    'hating life': 5,
    'pointless': 5,
    'no one cares': 5,
    'hopeless': 5,
    'give up': 5,
    'can\'t take it anymore': 6,
    'breaking down': 5,
    // Korean equivalents
    '절망': 5,            // Despair
    '포기': 5,            // Give up
    '못 버티겠어': 6,     // Can't endure
    
    // === MODERATE: Bullying / Violence (5 points) ===
    'bullying': 5,
    'hurt them': 6,
    'attack': 5,
    // Korean equivalents
    '괴롭힘': 5,          // Bullying
    '때리고 싶어': 5,     // Want to hit
    
    // === MILD: General distress (2-4 points) ===
    'stressed': 2,
    'anxious': 2,
    'worried': 2,
    'scared': 2,
    'overwhelmed': 4,
    '힘들어': 4,          // It's hard
    // Korean equivalents
    '스트레스': 2,
    '불안': 2,
  };

  // ============================================================
  // DETECTION METHODS
  // ============================================================

  /// Analyzes text for crisis indicators.
  /// 
  /// Scans the input text for weighted keywords and calculates
  /// a cumulative risk score. Returns the appropriate risk level
  /// or null if no crisis indicators are detected.
  /// 
  /// [text] The user's input text to analyze.
  /// 
  /// Returns [RiskLevel] or null if score is 0.
  /// 
  /// Example:
  /// ```dart
  /// final risk = CrisisService.analyzeForCrisis("I feel so hopeless");
  /// // Returns: RiskLevel.medium (5 points)
  /// ```
  static RiskLevel? analyzeForCrisis(String text) {
    if (text.isEmpty) return null;
    
    // Normalize text for matching (lowercase, remove punctuation)
    final normalizedText = text
        .toLowerCase()
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s]", unicode: true), "");
    
    int riskScore = 0;
    
    // Check each keyword and accumulate score
    _redFlagKeywords.forEach((keyword, weight) {
      final normalizedKeyword = keyword
          .toLowerCase()
          .replaceAll(RegExp(r"[^\p{L}\p{N}\s]", unicode: true), "");
      
      if (normalizedKeyword.isEmpty) return;
      
      if (normalizedText.contains(normalizedKeyword)) {
        riskScore += weight;
      }
    });

    // Classify risk level based on score
    if (riskScore >= 10) return RiskLevel.high;
    if (riskScore >= 5) return RiskLevel.medium;
    if (riskScore > 0) return RiskLevel.low;
    
    return null;
  }

  // ============================================================
  // RESPONSE GENERATION
  // ============================================================

  /// Gets appropriate crisis response based on risk level.
  /// 
  /// Returns a [CrisisResponse] with a supportive message and
  /// optional action (hotline call, counselor connection, or
  /// breathing exercise).
  /// 
  /// [level] The detected risk level.
  /// [isEnglish] Whether to return English (true) or Korean (false).
  /// 
  /// Example:
  /// ```dart
  /// final response = CrisisService.getSafetyInfo(RiskLevel.high, true);
  /// print(response.message);
  /// print(response.actionLabel); // "Call 109 (Crisis Hotline)"
  /// ```
  static CrisisResponse getSafetyInfo(RiskLevel level, bool isEnglish) {
    switch (level) {
      // === HIGH RISK: Immediate crisis intervention ===
      case RiskLevel.high:
        return CrisisResponse(
          isEnglish 
            ? "I'm really worried about you and I want to make sure you're "
              "safe. You're not alone, and there are people who want to help "
              "right now. Would you like me to connect you with someone?"
            : "네가 많이 걱정돼서 안전한지 확인하고 싶어. 넌 혼자가 아니고, "
              "지금 바로 널 도와주고 싶어하는 사람들이 있어. "
              "도움을 줄 수 있는 분께 연결해줄까?",
          actionLabel: isEnglish 
              ? "Call 109 (Crisis Hotline)" 
              : "109 자살예방상담전화 연결",
          actionUrl: "tel:109",
          action: CrisisAction.callHotline,
        );
        
      // === MEDIUM RISK: Warm handoff with options ===
      case RiskLevel.medium:
        return CrisisResponse(
          isEnglish
            ? "It sounds like you're going through something really difficult "
              "right now. That takes courage to share. 🦊 I'm here with you. "
              "Would you like to try a quick breathing exercise together, or "
              "would you prefer to talk to someone who specializes in helping?"
            : "지금 정말 힘든 일을 겪고 있는 것 같아. 그걸 나눠줘서 고마워. "
              "🦊 내가 여기 있을게. 같이 호흡 운동을 해볼까, 아니면 "
              "전문 상담사와 이야기해볼래?",
          actionLabel: isEnglish 
              ? "Talk to a Counselor" 
              : "상담사와 대화하기",
          actionUrl: "tel:1393", // Youth counseling hotline (Korea)
          action: CrisisAction.warmHandoff,
        );
        
      // === LOW RISK: Gentle coping support ===
      case RiskLevel.low:
        return CrisisResponse(
          isEnglish
            ? "I can feel that things are tough right now. Take a slow, deep "
              "breath with me. 🦊 You're doing your best, and that's enough. "
              "Want to try a 1-minute breathing exercise?"
            : "지금 많이 힘들구나. 나랑 같이 천천히 깊게 숨을 쉬어보자. 🦊 "
              "넌 최선을 다하고 있어, 그거면 충분해. 1분 호흡 운동 해볼래?",
          actionLabel: isEnglish 
              ? "Start Breathing Exercise" 
              : "호흡 운동 시작",
          action: CrisisAction.breathingExercise,
        );
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Launches the crisis hotline call.
  /// 
  /// [url] The tel: URL to launch (e.g., "tel:109").
  static Future<void> callCrisisHotline(String? url) async {
    if (url == null) return;
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Gets the appropriate color for crisis UI elements.
  /// 
  /// [level] The risk level to get color for.
  /// 
  /// Returns:
  /// - High: Red (#E53935)
  /// - Medium: Orange (#FF9800)
  /// - Low: Blue (#2196F3)
  static Color getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return const Color(0xFFE53935); // Red - Urgent
      case RiskLevel.medium:
        return const Color(0xFFFF9800); // Orange - Caution
      case RiskLevel.low:
        return const Color(0xFF2196F3); // Blue - Calm
    }
  }

  /// Gets the appropriate icon for the risk level.
  /// 
  /// [level] The risk level to get icon for.
  /// 
  /// Returns:
  /// - High: Warning icon
  /// - Medium: Heart icon
  /// - Low: Spa/wellness icon
  static IconData getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return Icons.warning_rounded;
      case RiskLevel.medium:
        return Icons.favorite_border;
      case RiskLevel.low:
        return Icons.spa_outlined;
    }
  }
}
