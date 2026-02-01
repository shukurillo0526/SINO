# SINO Architecture Guide

This document provides a detailed overview of the SINO application architecture.

## Overview

SINO follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION                             │
│  Screens, Features, Widgets                                      │
├─────────────────────────────────────────────────────────────────┤
│                          BUSINESS                                │
│  Controllers (Provider), Services                                │
├─────────────────────────────────────────────────────────────────┤
│                            DATA                                  │
│  Supabase, SharedPreferences, OpenRouter API                     │
└─────────────────────────────────────────────────────────────────┘
```

## State Management

SINO uses **Provider** for state management with a hybrid approach:

### Controllers (ChangeNotifier)
Manage UI state and user interactions:

```dart
class MoodController with ChangeNotifier {
  List<MoodEntry> _entries = [];
  
  Future<void> addEntry(MoodEntry entry) async {
    _entries.add(entry);
    notifyListeners();
    await _persist();
  }
}
```

### Services (Singleton/Static)
Handle business logic without UI state:

```dart
class CrisisService {
  static RiskLevel? analyzeForCrisis(String text) {
    // Pure function, no state
  }
}
```

## Data Flow

### User Input Flow
```
User Input
    │
    ▼
┌─────────────┐
│   Screen    │ (presentation)
└─────┬───────┘
      │
      ▼
┌─────────────┐
│ Controller  │ (state management)
└─────┬───────┘
      │
      ▼
┌─────────────┐
│   Service   │ (business logic)
└─────┬───────┘
      │
      ▼
┌─────────────┐
│    Data     │ (persistence)
└─────────────┘
```

### AI Chat Flow
```
User Message
    │
    ▼
┌──────────────────┐
│ CharacterScreen  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  GeminiService   │──────────────┐
└────────┬─────────┘              │
         │                        ▼
         │              ┌──────────────────┐
         │              │ConversationService│
         │              └──────────────────┘
         ▼
┌──────────────────┐
│   OpenRouter     │
│    (Gemini)      │
└──────────────────┘
```

## Directory Structure

```
lib/
├── main.dart                 # Entry point, provider setup
│
├── controllers/              # State management
│   ├── mood_controller.dart     # Mood entries
│   ├── rewards_controller.dart  # Points & rewards
│   ├── theme_controller.dart    # Dark/light mode
│   ├── language_controller.dart # EN/KO toggle
│   ├── mindfulness_controller.dart
│   └── consent_controller.dart
│
├── services/                 # Business logic
│   ├── gemini_service.dart      # AI chat
│   ├── crisis_service.dart      # Crisis detection
│   ├── conversation_service.dart # AI memory
│   ├── sentiment_service.dart   # Text analysis
│   ├── analytics_service.dart   # B2B data
│   ├── academics_service.dart   # Tasks
│   ├── clinical_export_service.dart
│   ├── supabase_auth_service.dart
│   ├── supabase_data_service.dart
│   ├── quiz_service.dart
│   └── voice_service.dart
│
├── models/                   # Data classes
│   ├── mood_models.dart
│   ├── academics_models.dart
│   └── user_model.dart
│
├── screens/                  # Main screens
│   ├── home.dart
│   ├── login.dart
│   ├── settings.dart
│   ├── account.dart
│   └── ...
│
├── features/                 # Feature modules
│   ├── character/
│   │   ├── character_screen.dart
│   │   └── character_prompt.dart
│   ├── mood/
│   │   ├── mood_screen.dart
│   │   └── parent_dashboard_screen.dart
│   ├── academics/
│   ├── games/
│   ├── mindfulness/
│   ├── b2b/
│   └── ...
│
├── widgets/                  # Reusable components
│   └── interactive_ibn_sina.dart
│
└── assets/                   # Static assets
    ├── sino_fox.png
    ├── questions_en.json
    └── questions_ko.json
```

## Key Design Patterns

### 1. Singleton Pattern
Used for services that need shared state:

```dart
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal() {
    _initialize();
  }
}
```

### 2. Provider Pattern
Used for reactive state management:

```dart
// Registration in main.dart
ChangeNotifierProvider(create: (_) => MoodController()),

// Usage in widgets
final mood = context.watch<MoodController>();
```

### 3. Repository Pattern
Used for data access abstraction:

```dart
class SupabaseDataService {
  Future<List<MoodEntry>> fetchMoodEntries() async {
    if (_isGuest) return _loadLocal();
    return _loadFromSupabase();
  }
}
```

### 4. Strategy Pattern
Used for crisis response:

```dart
switch (riskLevel) {
  case RiskLevel.high:
    return _getHighRiskResponse();
  case RiskLevel.medium:
    return _getMediumRiskResponse();
  case RiskLevel.low:
    return _getLowRiskResponse();
}
```

## Service Dependencies

```
┌─────────────────────────────────────────────────────┐
│                    main.dart                        │
│         (Registers all providers)                   │
└───────────────────────┬─────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────┐   ┌───────────┐   ┌───────────┐
│  Mood     │   │  Rewards  │   │  Theme    │
│Controller │   │Controller │   │Controller │
└─────┬─────┘   └─────┬─────┘   └───────────┘
      │               │
      ▼               ▼
┌───────────┐   ┌───────────┐
│ Supabase  │   │ Supabase  │
│DataService│   │DataService│
└───────────┘   └───────────┘

┌───────────┐   ┌───────────┐
│  Gemini   │──▶│Conversation│
│  Service  │   │  Service  │
└───────────┘   └───────────┘
```

## Testing Strategy

### Unit Tests
```
test/
├── unit_tests.dart       # Service & controller tests
└── widget_test.dart      # Basic widget tests
```

### Test Coverage Areas
1. **Controllers**: State mutations, persistence
2. **Services**: Business logic, API responses
3. **Models**: Serialization, validation
4. **Widgets**: Basic rendering, interactions

## Security Considerations

1. **API Keys**: Stored in `.env`, never committed
2. **RLS**: All Supabase tables use Row Level Security
3. **Anonymization**: B2B data is aggregated, no PII
4. **Crisis Data**: Logged locally, not synced without consent

## Performance Optimizations

1. **Lazy Loading**: Quiz questions loaded on demand
2. **Debouncing**: Typing analysis uses time windows
3. **Caching**: Conversation history bounded to 10 messages
4. **Pagination**: Mood entries loaded in batches

---

<p align="center">
  <strong>SINO Architecture Guide v1.3.0</strong>
</p>
