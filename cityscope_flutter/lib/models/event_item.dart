import 'package:flutter/material.dart';

class EventItem {
  const EventItem({
    required this.emoji,
    required this.name,
    required this.description,
    required this.happinessBoost,
    required this.costM,
    required this.accent,
  });

  final String emoji;
  final String name;
  final String description;
  final int happinessBoost;
  final double costM;
  final Color accent;
}
