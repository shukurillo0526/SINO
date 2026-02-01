/// SINO - Language Controller
/// 
/// Manages the application's language settings (English/Korean).
/// 
/// ## Features
/// - Language toggle (EN/KO)
/// - Simple boolean getters for UI logic
/// 
/// ## Usage
/// ```dart
/// final lang = Provider.of<LanguageController>(context);
/// Text(lang.isEnglish ? 'Hello' : '안녕하세요');
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/material.dart';

// ============================================================
// ENUMS
// ============================================================

/// Supported application languages.
enum AppLanguage { 
  /// English (US)
  en, 
  
  /// Korean (Korea)
  ko 
}

// ============================================================
// LANGUAGE CONTROLLER
// ============================================================

/// Controller for managing active app language.
class LanguageController extends ChangeNotifier {
  // ============================================================
  // PROPERTIES
  // ============================================================
  
  AppLanguage _current = AppLanguage.en;

  // ============================================================
  // GETTERS
  // ============================================================
  
  /// The currently selected language.
  AppLanguage get current => _current;

  /// Whether English is selected.
  bool get isEnglish => _current == AppLanguage.en;
  
  /// Whether Korean is selected.
  bool get isKorean => _current == AppLanguage.ko;

  // ============================================================
  // METHODS
  // ============================================================

  /// Toggles between English and Korean.
  void toggle() {
    _current = _current == AppLanguage.en ? AppLanguage.ko : AppLanguage.en;
    notifyListeners();
  }
  
  /// Sets the language explicitly.
  void setLanguage(AppLanguage language) {
    if (_current != language) {
      _current = language;
      notifyListeners();
    }
  }
}
