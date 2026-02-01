# Contributing to SINO

Thank you for your interest in contributing to SINO! This document provides guidelines and best practices for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [File Structure Guidelines](#file-structure-guidelines)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)

---

## 📜 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Prioritize user privacy and mental health safety
- Follow Flutter and Dart best practices

---

## 🛠️ Development Setup

### Prerequisites

```bash
# Verify Flutter installation
flutter doctor

# Required versions
Flutter: ^3.10.7
Dart: ^3.0.0
```

### Environment Configuration

1. Copy `.env.example` to `.env`
2. Fill in required API keys
3. Never commit `.env` to version control

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Code analysis
flutter analyze
```

---

## 📝 Coding Standards

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.

#### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | UpperCamelCase | `MoodController` |
| Files | snake_case | `mood_controller.dart` |
| Variables | lowerCamelCase | `sentimentScore` |
| Constants | lowerCamelCase | `maxHistoryLength` |
| Private members | _prefix | `_isInitialized` |

#### Documentation Comments

```dart
/// A service for managing AI chat interactions.
/// 
/// This service handles communication with the OpenRouter API
/// to provide conversational AI capabilities for the SINO companion.
/// 
/// Example usage:
/// ```dart
/// final gemini = GeminiService();
/// final response = await gemini.getChatResponse('Hello!');
/// ```
class GeminiService {
  /// Sends a message to the AI and returns the response.
  /// 
  /// [message] The user's input message.
  /// 
  /// Returns a [Future<String>] containing the AI's response.
  /// 
  /// Throws [TimeoutException] if the request exceeds 30 seconds.
  Future<String> getChatResponse(String message) async {
    // Implementation
  }
}
```

### Widget Guidelines

#### StatelessWidget Template

```dart
/// A widget that displays [description].
/// 
/// This widget is used in [context where it's used].
class MyWidget extends StatelessWidget {
  /// Creates a [MyWidget].
  /// 
  /// [requiredParam] is required because [reason].
  /// [optionalParam] defaults to [default value].
  const MyWidget({
    super.key,
    required this.requiredParam,
    this.optionalParam = defaultValue,
  });

  /// Description of this parameter.
  final String requiredParam;

  /// Description of this parameter.
  final int optionalParam;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

#### StatefulWidget Template

```dart
/// A stateful widget that manages [description].
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // ============================================================
  // PROPERTIES
  // ============================================================
  
  late final TextEditingController _controller;
  bool _isLoading = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // METHODS
  // ============================================================

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    // Implementation
    setState(() => _isLoading = false);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Service Guidelines

```dart
/// Service for [purpose].
/// 
/// This service follows the Singleton pattern to ensure
/// consistent state across the application.
/// 
/// ## Usage
/// ```dart
/// final service = MyService();
/// await service.doSomething();
/// ```
/// 
/// ## Dependencies
/// - [DependencyA] for [reason]
/// - [DependencyB] for [reason]
class MyService {
  // ============================================================
  // SINGLETON PATTERN
  // ============================================================
  
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();

  // ============================================================
  // CONSTANTS
  // ============================================================
  
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);

  // ============================================================
  // PROPERTIES
  // ============================================================
  
  bool _initialized = false;
  
  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  /// Initializes the service with required configuration.
  Future<void> initialize() async {
    // Implementation
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  Future<void> _internalHelper() async {
    // Implementation
  }
}
```

---

## 📁 File Structure Guidelines

### Feature-based Organization

```
lib/features/mood/
├── mood_screen.dart           # Main screen
├── widgets/                   # Feature-specific widgets
│   ├── mood_chart.dart
│   └── mood_selector.dart
├── mood_service.dart          # Feature-specific logic (if needed)
└── README.md                  # Feature documentation
```

### Service Organization

```
lib/services/
├── interfaces/                # Abstract service definitions
│   └── i_auth_service.dart
├── gemini_service.dart        # AI service
├── crisis_service.dart        # Crisis detection
└── README.md                  # Services documentation
```

---

## 📖 Documentation Standards

### File Headers

Each Dart file should begin with a file-level documentation comment:

```dart
/// SINO - Mood Controller
/// 
/// This controller manages mood entry state and persistence.
/// It supports both local (guest) and cloud (authenticated) storage.
/// 
/// ## Responsibilities
/// - Loading and saving mood entries
/// - Generating weekly reports
/// - Managing crisis alerts
/// 
/// ## Dependencies
/// - [SupabaseDataService] for cloud storage
/// - [SharedPreferences] for local storage
/// 
/// @author SINO Team
/// @since 1.0.0
library;

import 'package:flutter/material.dart';
// ... other imports
```

### Inline Comments

Use inline comments sparingly and meaningfully:

```dart
// GOOD: Explains WHY
// We limit history to 10 messages to prevent token overflow
// with the AI model's context window limit.
_trimHistory();

// BAD: Explains WHAT (obvious from code)
// Trim the history
_trimHistory();
```

### TODO Comments

```dart
// TODO(username): Description of what needs to be done
// See: https://github.com/org/repo/issues/123

// FIXME(username): Description of bug to fix
// This causes issues when [condition]
```

---

## 🔄 Pull Request Process

### Before Submitting

1. **Run all tests**: `flutter test`
2. **Run analyzer**: `flutter analyze`
3. **Format code**: `dart format .`
4. **Update documentation** if adding new features
5. **Add tests** for new functionality

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process

1. At least one approval required
2. All CI checks must pass
3. No merge conflicts
4. Documentation complete

---

## 🏷️ Version Management

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

Update version in `pubspec.yaml`:
```yaml
version: 1.2.3+45  # major.minor.patch+build
```

---

## 📞 Questions?

- Open a GitHub Issue
- Contact: dev@sino-app.com

Thank you for contributing to SINO! 🦊
