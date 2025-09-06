import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  late final Box _settingsBox;

  ThemeModeNotifier() : super(ThemeMode.system) {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      final savedThemeIndex = _settingsBox.get(_themeKey, defaultValue: 0);
      state = ThemeMode.values[savedThemeIndex];
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    final nextTheme = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    
    state = nextTheme;
    await _settingsBox.put(_themeKey, nextTheme.index);
  }

  IconData get currentThemeIcon => switch (state) {
    ThemeMode.system => Icons.brightness_auto,
    ThemeMode.light => Icons.light_mode,
    ThemeMode.dark => Icons.dark_mode,
  };

  String get currentThemeTooltip => switch (state) {
    ThemeMode.system => 'System theme',
    ThemeMode.light => 'Light theme',
    ThemeMode.dark => 'Dark theme',
  };
}

final themeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});