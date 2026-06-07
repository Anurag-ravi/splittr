import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/providers/shared_preferences_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(
    ref.read(sharedPreferencesProvider),
  ),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_loadTheme(_prefs));

  final SharedPreferences _prefs;

  static const _key = 'theme_mode';

  static ThemeMode _loadTheme(
    SharedPreferences prefs,
  ) {
    final value = prefs.getString(_key);

    switch (value) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    String value = 'system';

    if (mode == ThemeMode.light) {
      value = 'light';
    } else if (mode == ThemeMode.dark) {
      value = 'dark';
    }

    await _prefs.setString(_key, value);
  }
}
