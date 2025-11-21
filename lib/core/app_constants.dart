import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4CAF50); // Green
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color textDark = Color(0xFF212121); // Dark Gray
  static const Color textLight = Colors.white;
}

class AppConstants {
  static const List<String> chickenTypes = [
    'Broiler',
    'Layer',
    'Dual Purpose',
    'Indigenous'
  ];

  static const Map<String, List<Map<String, dynamic>>> vaccinationSchedule = {
    'Broiler': [
      {'day': 7, 'vaccine': 'Newcastle Disease (ND)'},
      {'day': 14, 'vaccine': 'Infectious Bursal Disease (IBD)'},
      {'day': 21, 'vaccine': 'ND Booster'},
    ],
    'Layer': [
      {'day': 7, 'vaccine': 'Marek\'s Disease'},
      {'day': 14, 'vaccine': 'ND/IBD'},
      {'day': 28, 'vaccine': 'Fowl Pox'},
    ],
    // ... other types
  };
}
