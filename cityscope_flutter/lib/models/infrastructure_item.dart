import 'package:flutter/material.dart';

class InfrastructureItem {
  const InfrastructureItem({
    required this.emoji,
    required this.name,
    required this.costM,
    required this.populationImpact,
    required this.happinessImpact,
    required this.pollutionImpact,
    required this.accent,
  });

  final String emoji;
  final String name;
  final double costM;
  final int populationImpact;
  final int happinessImpact;
  final int pollutionImpact;
  final Color accent;

  String get costLabel => '\$${costM.toStringAsFixed(1)}M';
}
