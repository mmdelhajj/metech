import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:active_ecommerce_cms_demo_app/my_theme.dart';

/// App theme preference: light, dark, or follow system.
/// Persists user choice across app restarts.
class ThemeProvider with ChangeNotifier {
  static const _prefsKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    switch (raw) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
    _applyMyThemeColors();
    notifyListeners();
  }

  /// Resolve the current effective brightness and push it into MyTheme,
  /// so screens that hardcode `MyTheme.white` etc. get dark-mode colors.
  void _applyMyThemeColors() {
    Brightness brightness;
    if (_mode == ThemeMode.dark) {
      brightness = Brightness.dark;
    } else if (_mode == ThemeMode.light) {
      brightness = Brightness.light;
    } else {
      brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
    }
    MyTheme.applyMode(brightness);
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    _applyMyThemeColors();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_prefsKey, value);
  }
}
