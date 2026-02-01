# SINO Services

This directory contains all business logic and API integration services for the SINO application.

## 📋 Service Overview

| Service | Purpose | Type |
|---------|---------|------|
| `gemini_service.dart` | AI chat with SINO companion | Singleton |
| `crisis_service.dart` | Crisis detection and intervention | Static utility |
| `conversation_service.dart` | Context memory for AI | ChangeNotifier |
| `analytics_service.dart` | B2B dashboard data | Instance |
| `academics_service.dart` | Academic task management | ChangeNotifier |
| `supabase_auth_service.dart` | Authentication | ChangeNotifier |
| `supabase_data_service.dart` | Database operations | Instance |
| `sentiment_service.dart` | Text sentiment analysis | Static utility |
| `clinical_export_service.dart` | CSV export for reports | Instance |
| `voice_service.dart` | Audio recording | Instance |
| `quiz_service.dart` | Quiz game logic | Instance |
| `openai_service.dart` | Legacy OpenAI integration | Deprecated |

## 🏗️ Architecture Patterns

### Singleton Pattern
Used for services that need shared state across the app:

```dart
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();
}
```

### ChangeNotifier Pattern
Used for services that expose reactive state:

```dart
class ConversationService with ChangeNotifier {
  List<Memory> _memories = [];
  
  void addMemory(Memory m) {
    _memories.add(m);
    notifyListeners();
  }
}
```

### Static Utility Pattern
Used for stateless utility functions:

```dart
class CrisisService {
  static RiskLevel? analyzeForCrisis(String text) {
    // Pure function, no state
  }
}
```

## 🔌 Service Dependencies

```
GeminiService
    └── ConversationService (for context memory)

MoodController
    └── SupabaseDataService (for cloud storage)
    └── CrisisService (for risk detection)

AcademicsService
    └── SupabaseDataService (for cloud storage)
```

## 📁 Directory Structure

```
services/
├── interfaces/              # Abstract service definitions
│   └── i_auth_service.dart  # Auth service interface
├── gemini_service.dart      # AI chat service
├── crisis_service.dart      # Crisis detection
├── conversation_service.dart # AI memory
├── analytics_service.dart   # B2B analytics
├── academics_service.dart   # Task management
├── supabase_auth_service.dart # Authentication
├── supabase_data_service.dart # Database ops
├── sentiment_service.dart   # Text analysis
├── clinical_export_service.dart # CSV export
├── voice_service.dart       # Audio recording
├── quiz_service.dart        # Quiz games
├── openai_service.dart      # (Legacy)
└── README.md               # This file
```

## 🛡️ Error Handling

All services follow consistent error handling:

```dart
try {
  // Attempt operation
  final result = await _apiCall();
  return result;
} catch (e) {
  // Log error
  debugPrint('❌ ServiceName error: $e');
  
  // Return default/fallback
  return fallbackValue;
}
```

## 🧪 Testing

Each service should have corresponding tests in `/test/services/`:

```
test/
└── services/
    ├── gemini_service_test.dart
    ├── crisis_service_test.dart
    └── ...
```

## 📝 Adding a New Service

1. Create the service file in `/lib/services/`
2. Follow the appropriate pattern (Singleton/ChangeNotifier/Static)
3. Add documentation header
4. Register in `main.dart` if needed
5. Update this README
6. Add tests
