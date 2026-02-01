/// SINO - Theme Controller
/// 
/// Manages the application's visual theme settings, including
/// light/dark mode and accessibility options like Big Icon Mode.
/// 
/// ## Features
/// - Light/Dark mode toggle
/// - Big Icon Mode (accessibility)
/// - Local persistence via SharedPreferences
/// 
/// ## Usage
/// ```dart
/// final themeController = Provider.of<ThemeController>(context);
/// themeController.toggleTheme(true); // Switch to dark mode
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// THEME CONTROLLER
// ============================================================

/// Controller for managing app-wide theme and display settings.
class ThemeController with ChangeNotifier {
  // ============================================================
  // CONSTANTS
  // ============================================================
  
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyBigIconMode = 'is_big_icon_mode';

  // ============================================================
  // PROPERTIES
  // ============================================================
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isBigIconMode = false;

  // ============================================================
  // GETTERS
  // ============================================================
  
  /// Current theme mode (light/dark/system).
  ThemeMode get themeMode => _themeMode;
  
  /// Whether dark mode is currently active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Whether big icon mode (accessibility) is enabled.
  bool get isBigIconMode => _isBigIconMode;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  
  ThemeController() {
    _loadSettings();
  }

  // ============================================================
  // METHODS
  // ============================================================

  /// Loads saved theme settings from local storage.
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isDark = prefs.getBool(_keyDarkMode) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      
      _isBigIconMode = prefs.getBool(_keyBigIconMode) ?? false;
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading theme settings: $e');
    }
  }

  /// Toggles between light and dark themes.
  /// 
  /// [isDark] true to enable dark mode, false for light mode.
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, isDark);
    } catch (e) {
      debugPrint('❌ Error saving theme setting: $e');
    }
  }

  /// Toggles Big Icon Mode for improved accessibility.
  /// 
  /// [enabled] true to enable larger icons throughout the app.
  Future<void> toggleBigIconMode(bool enabled) async {
    _isBigIconMode = enabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBigIconMode, enabled);
    } catch (e) {
      debugPrint('❌ Error saving big icon setting: $e');
    }
  }
}
