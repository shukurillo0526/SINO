# SINO Platform Documentation

**Version:** 1.3.0  
**Last Updated:** 2026-01-20  
**Platform:** Flutter (Cross-platform Mobile/Web)

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Technology Stack](#2-technology-stack)
3. [Architecture Overview](#3-architecture-overview)
4. [Core Features](#4-core-features)
5. [AI Integration](#5-ai-integration)
6. [Data Management](#6-data-management)
7. [Security & Privacy](#7-security--privacy)
8. [API Reference](#8-api-reference)
9. [Deployment](#9-deployment)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Executive Summary

SINO is a comprehensive student wellness companion application designed to support mental well-being, academic success, and engagement through gamification. The platform integrates:

- **AI-Powered Companion**: Conversational character (SINO the fox) for emotional support
- **Mood Tracking**: Multi-source mood logging with sentiment analysis
- **Crisis Detection**: Real-time intervention for concerning language
- **Academic Tools**: Schedule and task management with rewards
- **Gamification**: Points economy with unlockable rewards
- **B2B Analytics**: Anonymized dashboards for educational institutions

### Target Users
- **Primary**: Students (ages 13-22)
- **Secondary**: Parents/Guardians (dashboard access)
- **Tertiary**: School Administrators (B2B analytics)

### Supported Languages
- English (en-US)
- Korean (ko-KR)

---

## 2. Technology Stack

### Core Framework
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.10.7+ |
| Language | Dart | 3.0.0+ |
| Design System | Material 3 | Latest |

### Backend Services
| Service | Provider | Purpose |
|---------|----------|---------|
| Database | Supabase (PostgreSQL) | Data persistence |
| Authentication | Supabase Auth | OAuth, email login |
| Realtime | Supabase Realtime | Live updates |
| AI | OpenRouter | Gemini 2.0 Flash |

### Key Dependencies
```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  
  # Backend
  supabase_flutter: ^2.12.0
  
  # AI/ML
  http: ^1.2.2
  
  # UI/UX
  fl_chart: ^1.1.1
  flutter_tts: ^4.2.5
  
  # Media
  record: ^5.1.0
  audioplayers: ^6.5.1
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Utilities
  flutter_dotenv: ^5.1.0
  intl: ^0.18.1
```

---

## 3. Architecture Overview

### Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │   Screens   │ │  Features   │ │   Widgets   │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
├─────────────────────────────────────────────────────────────┤
│                      BUSINESS LAYER                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │ Controllers │ │  Services   │ │   Models    │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
├─────────────────────────────────────────────────────────────┤
│                        DATA LAYER                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │  Supabase   │ │SharedPrefs  │ │  OpenRouter │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── main.dart              # Application entry point
│
├── controllers/           # State Management (Provider)
│   ├── mood_controller.dart
│   ├── rewards_controller.dart
│   ├── theme_controller.dart
│   ├── language_controller.dart
│   ├── mindfulness_controller.dart
│   └── consent_controller.dart
│
├── services/              # Business Logic & APIs
│   ├── gemini_service.dart       # AI chat
│   ├── crisis_service.dart       # Crisis detection
│   ├── conversation_service.dart # AI memory
│   ├── analytics_service.dart    # B2B data
│   ├── academics_service.dart    # Tasks/Schedule
│   ├── supabase_auth_service.dart
│   ├── supabase_data_service.dart
│   └── ...
│
├── models/                # Data Classes
│   ├── mood_models.dart
│   ├── academics_models.dart
│   └── user_model.dart
│
├── screens/               # Main Screens
│   ├── home.dart
│   ├── login.dart
│   ├── settings.dart
│   └── ...
│
├── features/              # Feature Modules
│   ├── character/         # SINO AI companion
│   ├── mood/              # Mood tracking
│   ├── academics/         # Task management
│   ├── games/             # Mini-games
│   ├── mindfulness/       # Wellness activities
│   ├── b2b/               # Admin dashboard
│   └── ...
│
├── widgets/               # Reusable Components
└── assets/                # Static Assets
```

---

## 4. Core Features

### 4.1 Authentication System

**Providers:**
- **Kakao OAuth**: Primary login for Korean users
- **Guest Mode**: Local-only session without account

**Implementation:**
```dart
class SupabaseAuthService with ChangeNotifier {
  // Observes Supabase onAuthStateChange stream
  // Merges with local guest state via RxDart BehaviorSubject
  // Handles OAuth deep links: com.sino.app.sino://login-callback/
}
```

### 4.2 Mood Tracking

**Input Sources:**
| Source | Method | Sentiment |
|--------|--------|-----------|
| Manual | Emoji tap | Direct mapping |
| Voice | Audio recording | Keyword analysis |
| Chat | Conversation | AI-derived |
| Games | Performance | Score-based |
| Tasks | Completion | Positive boost |

**Sentiment Scoring:**
```
+0.8  Very Happy (😄)
+0.5  Happy (😊)
 0.0  Neutral (😐)
-0.4  Sad (😢)
-0.6  Stressed (😫)
-0.8  Very Sad (😭)
```

### 4.3 Crisis Detection

**Three-Tier Risk System:**

| Level | Score | Action |
|-------|-------|--------|
| High | ≥10 | Connect to 109 crisis hotline |
| Medium | 5-9 | Warm handoff to 1393 counselor |
| Low | 1-4 | Breathing exercise offer |

**Keyword Categories:**
- **Critical (10pts)**: suicide, self-harm, 자살, 자해
- **Severe (5-6pts)**: hopeless, can't take it, 절망
- **Moderate (2-4pts)**: stressed, anxious, 힘들어

### 4.4 AI Companion (SINO)

**Character Profile:**
- **Name**: SINO (시노)
- **Type**: Friendly fox companion 🦊
- **Personality**: Warm, encouraging, non-judgmental

**AI Configuration:**
```dart
static const String _model = 'google/gemini-2.0-flash-exp:free';
static const int _maxHistoryLength = 10;
static const Duration _timeout = Duration(seconds: 30);
```

**Proactive Interventions:**
- 3+ upcoming exams + stressed mood → Offer breathing exercise
- 3+ overdue tasks → Offer task breakdown help
- Very sad mood detected → Offer to talk

### 4.5 Academic Tools

**Features:**
- Weekly class schedule with color coding
- To-do list with priority levels
- Deadline tracking with notifications
- Task completion rewards (+10 SINO Points)

### 4.6 Gamification

**SINO Points Economy:**
| Action | Points |
|--------|--------|
| Complete task | +10 |
| Play mini-game | +5-20 |
| Daily check-in | +5 |
| Mindfulness session | +15 |

**Rewards Shop:**
- Character skins (e.g., "Confu", "Scientist")
- Real-world coupons (configurable by institution)

---

## 5. AI Integration

### OpenRouter Configuration

**Endpoint:** `https://openrouter.ai/api/v1/chat/completions`

**Headers:**
```
Authorization: Bearer {OPENROUTER_API_KEY}
Content-Type: application/json
HTTP-Referer: https://sino-app.com
X-Title: SINO
```

**Request Body:**
```json
{
  "model": "google/gemini-2.0-flash-exp:free",
  "messages": [
    {"role": "system", "content": "...system prompt..."},
    {"role": "user", "content": "...user message..."}
  ],
  "max_tokens": 150,
  "temperature": 0.7
}
```

### Conversation Memory

The `ConversationService` maintains short-term context:
- Last 20 conversation topics
- Stressors and achievements
- User preferences
- Persisted to SharedPreferences

---

## 6. Data Management

### Supabase Tables

```sql
-- User mood entries
CREATE TABLE mood_entries (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  mood_level INT,
  sentiment_score FLOAT,
  source TEXT,
  context TEXT,
  created_at TIMESTAMPTZ
);

-- Academic tasks
CREATE TABLE academic_tasks (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  title TEXT,
  priority INT,
  due_date TIMESTAMPTZ,
  completed BOOLEAN,
  created_at TIMESTAMPTZ
);

-- User points
CREATE TABLE user_points (
  user_id UUID PRIMARY KEY REFERENCES auth.users,
  total_points INT,
  updated_at TIMESTAMPTZ
);
```

### Hybrid Storage Strategy

```
┌─────────────────────────────────────────┐
│              User Request               │
└────────────────┬────────────────────────┘
                 │
        ┌────────▼────────┐
        │  Is Logged In?  │
        └────────┬────────┘
                 │
    ┌────────────┴────────────┐
    │ YES                     │ NO
    ▼                         ▼
┌───────────┐           ┌───────────┐
│  Supabase │           │   Local   │
│  (Cloud)  │           │ (Prefs)   │
└───────────┘           └───────────┘
```

---

## 7. Security & Privacy

### Row Level Security (RLS)

All Supabase tables implement RLS:
```sql
CREATE POLICY "Users can only access own data"
ON mood_entries
FOR ALL
USING (auth.uid() = user_id);
```

### Data Privacy

| Data Type | Storage | Sharing |
|-----------|---------|---------|
| Mood entries | Encrypted | Consent-based |
| Chat history | Local only | Never |
| Crisis alerts | Aggregated | Admin dashboard |
| B2B analytics | Anonymized | Institution only |

### Anonymization for B2B

```sql
-- Analytics views return ONLY aggregated data
CREATE VIEW analytics_risk_distribution AS
SELECT 
  date_trunc('day', created_at) AS day,
  SUM(CASE WHEN sentiment_score > 0.2 THEN 1 ELSE 0 END) AS positive,
  SUM(CASE WHEN sentiment_score < -0.4 THEN 1 ELSE 0 END) AS high_risk
FROM mood_entries
GROUP BY day;
-- No user_id exposed
```

---

## 8. API Reference

### GeminiService

```dart
/// Gets a chat response from the AI.
Future<String> getChatResponse(String message);

/// Checks if proactive intervention is needed.
void checkForProactiveIntervention({
  required int upcomingExamCount,
  required MoodLevel? recentMood,
  required int overdueTasks,
});

/// Resets the conversation session.
void resetSession();
```

### CrisisService

```dart
/// Analyzes text for crisis indicators.
static RiskLevel? analyzeForCrisis(String text);

/// Gets appropriate crisis response.
static CrisisResponse getSafetyInfo(RiskLevel level, bool isEnglish);

/// Launches crisis hotline call.
static Future<void> callCrisisHotline(String? url);
```

### MoodController

```dart
/// Adds a manual mood entry.
Future<void> addManualMood(MoodLevel mood, {String? context});

/// Adds mood from external service.
Future<void> addMoodFromService(
  MoodSource source,
  double sentimentScore, {
  String? context,
  Map<String, dynamic>? metadata,
});

/// Gets weekly mood report.
WeeklyMoodReport getWeeklyReport();
```

---

## 9. Deployment

### Environment Variables

```env
# Required
OPENROUTER_API_KEY=sk-or-v1-...
SUPABASE_URL=https://xxx.supabase.co/
SUPABASE_ANON_KEY=eyJ...

# Optional (for Kakao OAuth)
KAKAO_CLIENT_ID=...
KAKAO_CLIENT_SECRET=...
```

### Build Commands

```bash
# Development
flutter run -d chrome

# Android Release
flutter build apk --release

# iOS Release
flutter build ios --release

# Web
flutter build web --release
```

### Platform Requirements

| Platform | Minimum Version |
|----------|-----------------|
| Android | API 21 (5.0) |
| iOS | 13.0 |
| Web | Chrome 80+ |

---

## 10. Troubleshooting

### Common Issues

**AI not responding:**
1. Check `OPENROUTER_API_KEY` in `.env`
2. Verify internet connectivity
3. Check console for timeout errors
4. Model may be rate-limited (try again later)

**Mood entries not saving:**
1. Check Supabase connection
2. Verify RLS policies
3. Check if user is authenticated (guest uses local storage)

**Kakao OAuth redirect failing:**
1. Verify deep link scheme: `com.sino.app.sino://login-callback/`
2. Check `AndroidManifest.xml` intent filters
3. Verify Kakao app settings match redirect URI

### Debug Logging

```dart
// Enable verbose logging in GeminiService
debugPrint('🦊 GeminiService: ${message}');
debugPrint('❌ Error: ${error}');
```

### Support Channels

- **Developer**: dev@sino-app.com
- **Documentation**: [docs.sino-app.com](https://docs.sino-app.com)
- **GitHub Issues**: [github.com/sino/issues](https://github.com/sino/issues)

---

<p align="center">
  <strong>SINO Platform Documentation v1.3.0</strong><br>
  Last updated: 2026-01-20
</p>
