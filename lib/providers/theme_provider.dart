import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'app_theme_mode';
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    _initPrefs();
    return ThemeMode.system; // Default before prefs load
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final val = _prefs.getString(_themeKey);
    if (val != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.toString() == val,
        orElse: () => ThemeMode.system,
      );
      state = mode;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeKey, mode.toString());
  }
}
