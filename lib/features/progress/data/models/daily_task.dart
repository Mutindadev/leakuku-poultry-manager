import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DailyTask {
  final String id;
  final String title;
  final String? subtitle;
  final FaIconData icon;
  final Color color;

  const DailyTask({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
  });
}
