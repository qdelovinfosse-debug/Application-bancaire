import 'package:flutter/material.dart';

/// Notifier global pour le thème — importé dans main.dart et settings_screen.dart
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
