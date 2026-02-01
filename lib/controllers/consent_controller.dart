import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentController extends ChangeNotifier {
  static const String _keyShareMood = 'consent_share_mood';
  static const String _keyShareAcademics = 'consent_share_academics';
  static const String _keyShareActivity = 'consent_share_activity';
  static const String _keyHasConsented = 'consent_has_consented_initially';

  bool _shareMood = true;
  bool _shareAcademics = true;
  bool _shareActivity = true;
  bool _hasConsentedInitially = false;

  bool get shareMood => _shareMood;
  bool get shareAcademics => _shareAcademics;
  bool get shareActivity => _shareActivity;
  bool get hasConsentedInitially => _hasConsentedInitially;

  ConsentController() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _shareMood = prefs.getBool(_keyShareMood) ?? true;
    _shareAcademics = prefs.getBool(_keyShareAcademics) ?? true;
    _shareActivity = prefs.getBool(_keyShareActivity) ?? true;
    _hasConsentedInitially = prefs.getBool(_keyHasConsented) ?? false;
    notifyListeners();
  }

  Future<void> toggleShareMood(bool val) async {
    _shareMood = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShareMood, val);
    notifyListeners();
  }

  Future<void> toggleShareAcademics(bool val) async {
    _shareAcademics = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShareAcademics, val);
    notifyListeners();
  }

  Future<void> toggleShareActivity(bool val) async {
    _shareActivity = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShareActivity, val);
    notifyListeners();
  }

  Future<void> markInitialConsentDone() async {
    _hasConsentedInitially = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasConsented, true);
    notifyListeners();
  }

  Future<void> wipeAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Reset local state if needed
    _shareMood = true;
    _shareAcademics = true;
    _shareActivity = true;
    _hasConsentedInitially = false;
    notifyListeners();
  }
}
