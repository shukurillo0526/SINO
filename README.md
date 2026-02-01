# SINO - Student Companion App 🦊

<p align="center">
  <img src="lib/assets/sino_fox.png" alt="SINO Logo" width="120"/>
</p>

<p align="center">
  <strong>A comprehensive student wellness and productivity companion</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## 📋 Overview

SINO is a Flutter-based mobile application designed to support student mental well-being, academic success, and engagement through gamification. The platform integrates mood tracking, crisis intervention, academic management, and mindfulness tools into a unified, AI-powered character companion.

## ✨ Features

### 🦊 AI Companion (SINO)
- Conversational AI powered by Google Gemini 2.0 Flash via OpenRouter
- Context-aware responses with conversation memory
- Proactive wellness interventions based on user patterns
- Multi-language support (English/Korean)

### 📊 Mood Tracking
- Manual mood logging with emoji scale
- Voice note recording and analysis
- Automated sentiment detection from interactions
- Weekly wellness reports with trend analysis

### 🚨 Crisis Detection
- Real-time text analysis for concerning language
- Tiered risk assessment (Low/Medium/High)
- Warm handoff protocols for moderate distress
- Direct crisis hotline integration (109)

### 📚 Academic Tools
- Weekly class schedule management
- Task/To-Do list with priority levels
- Completion rewards integration
- Academic stress correlation tracking

### 🎮 Gamification
- SINO Points economy for engagement
- Rewards shop with character skins and coupons
- Stress-relief mini-games
- Study drill quizzes with localized content

### 🏫 B2B Dashboard
- Anonymized aggregate analytics for schools
- Risk distribution visualization
- Wellness trend monitoring
- CSV export for clinical review

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.10.7
- Dart SDK ^3.0.0
- Android Studio / Xcode (for mobile development)
- Supabase account (for backend)
- OpenRouter API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/sino.git
   cd sino
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   Create a `.env` file in the project root:
   ```env
   OPENROUTER_API_KEY=your_openrouter_key
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   KAKAO_CLIENT_ID=your_kakao_client_id
   KAKAO_CLIENT_SECRET=your_kakao_client_secret
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

```
lib/
├── controllers/     # State management (Provider pattern)
│   ├── mood_controller.dart
│   ├── rewards_controller.dart
│   └── ...
├── features/        # Feature-specific screens and widgets
│   ├── character/   # SINO AI companion
│   ├── mood/        # Mood tracking
│   ├── academics/   # Academic tools
│   └── ...
├── models/          # Data classes and enums
│   ├── mood_models.dart
│   ├── academics_models.dart
│   └── user_model.dart
├── services/        # Business logic and API integrations
│   ├── gemini_service.dart
│   ├── crisis_service.dart
│   ├── supabase_auth_service.dart
│   └── ...
├── screens/         # Main application screens
│   ├── home.dart
│   ├── login.dart
│   └── ...
├── widgets/         # Reusable UI components
└── main.dart        # Application entry point
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [PLATFORM_DOCUMENTATION.md](PLATFORM_DOCUMENTATION.md) | Complete technical documentation |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [docs/API.md](docs/API.md) | API reference |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Detailed architecture guide |

## 🛠️ Technology Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10+ |
| **Language** | Dart 3.0+ |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime) |
| **AI/ML** | OpenRouter (Gemini 2.0 Flash) |
| **State Management** | Provider |
| **Local Storage** | SharedPreferences |
| **Charts** | fl_chart |
| **Voice** | record, flutter_tts |

## 🔐 Security & Privacy

- **Row Level Security (RLS)** on all Supabase tables
- **Anonymized analytics** for B2B dashboards
- **Consent-based data sharing** with parental controls
- **No personal data in crisis alerts** (only aggregated flags)

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (13.0+)
- ✅ Web (Chrome, Edge, Safari)
- ⚠️ Windows (limited - TTS dependencies)
- ⚠️ macOS (limited - TTS dependencies)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📄 License

This project is proprietary software. See [LICENSE](LICENSE) for details.

## 📞 Support

- **Email**: support@sino-app.com
- **Documentation**: [docs.sino-app.com](https://docs.sino-app.com)
- **Issues**: [GitHub Issues](https://github.com/your-org/sino/issues)

---

<p align="center">
  Made with ❤️ for student wellness
</p>
