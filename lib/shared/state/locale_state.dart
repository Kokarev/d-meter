import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user-selected app locale.
///
/// null  →  follow system (default on first launch)
/// 'en'  →  English, persisted
/// 'uk'  →  Ukrainian, persisted
class LocaleState extends ChangeNotifier {
  static const _prefKey = 'app_locale';
  static const Set<String> _supported = {
    'en',
    'uk',
  };

  Locale? _locale;
  Locale? get locale => _locale;

  /// Reads the saved locale from SharedPreferences.
  /// Call once before the first frame.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code  = prefs.getString(_prefKey);
    if (code != null && _supported.contains(code)) {
      _locale = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_supported.contains(locale.languageCode)) {
      throw ArgumentError(
        'Unsupported locale: ${locale.languageCode}. '
        'Supported: $_supported',
      );
    }
    // languageCode comparison — Locale('en') and Locale('en','US') are equal here
    if (_locale?.languageCode == locale.languageCode) return;
    _locale = Locale(locale.languageCode); // normalise — strip region
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
    notifyListeners();
  }

  /// Clears manual override — app follows system locale again.
  Future<void> resetToSystem() async {
    if (_locale == null) return;
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    notifyListeners();
  }

  /// Returns the toggle label for the given resolved language code.
  String displayCode(String currentCode) {
    return currentCode == 'uk' ? 'УК' : 'EN';
  }
}
