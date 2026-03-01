import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Gestion des préférences utilisateur via Hive (accès synchrone).
/// La box 'settings' doit être ouverte dans main() avant utilisation.
class SettingsHelper {
  static final SettingsHelper instance = SettingsHelper._init();
  static const String boxName = 'settings';

  SettingsHelper._init();

  Box get _box => Hive.box(boxName);

  // Devise
  String getCurrency() => _box.get('currency', defaultValue: '€') as String;
  Future<void> setCurrency(String currency) => _box.put('currency', currency);

  // Thème
  ThemeMode getThemeMode() {
    final value = _box.get('themeMode', defaultValue: 'dark') as String;
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
      default:
        value = 'dark';
    }
    return _box.put('themeMode', value);
  }

  // Budget mensuel
  double getMonthlyBudget() =>
      (_box.get('monthlyBudget', defaultValue: 0.0) as num).toDouble();
  Future<void> setMonthlyBudget(double budget) =>
      _box.put('monthlyBudget', budget);
}
