import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> categories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Loisirs',
    'Santé',
    'Autres',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Alimentation': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Logement': Icons.home,
    'Loisirs': Icons.sports_esports,
    'Santé': Icons.local_hospital,
    'Autres': Icons.more_horiz,
  };

  static const Map<String, Color> categoryColors = {
    'Alimentation': Colors.orange,
    'Transport': Colors.blue,
    'Logement': Colors.green,
    'Loisirs': Colors.purple,
    'Santé': Colors.red,
    'Autres': Colors.grey,
  };
}
