import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'event_item.dart';
import 'infrastructure_item.dart';

class CityAppState {
  double maxBudgetM = 10;
  double allocatedBudgetM = 8.4;
  int happiness = 74;
  int pollution = 38;
  int traffic = 62;
  int population = 124830;
  int greenery = 24;
  int industrialZones = 3;
  int buildingsBuilt = 12;
  int eventsHosted = 4;
  String cityName = 'Nova City';
  DateTime startTime = DateTime.now();

  InfrastructureItem? selectedInfrastructure;
  EventItem? activeEvent;

  final List<String> activities = <String>[
    'Hospital constructed in North District.',
    'Central Park expanded, improving air quality.',
    'Power grid upgraded for 3 neighborhoods.',
    'Traffic lights optimized on Main Avenue.',
  ];

  final List<InfrastructureItem> infrastructureItems = const <InfrastructureItem>[
    InfrastructureItem(
      emoji: '🌳',
      name: 'Park',
      costM: 0.2,
      populationImpact: 1500,
      happinessImpact: 12,
      pollutionImpact: -8,
      accent: AppTheme.green,
    ),
    InfrastructureItem(
      emoji: '🏥',
      name: 'Hospital',
      costM: 1.2,
      populationImpact: 5000,
      happinessImpact: 18,
      pollutionImpact: 2,
      accent: Colors.red,
    ),
    InfrastructureItem(
      emoji: '🏫',
      name: 'School',
      costM: 0.8,
      populationImpact: 3000,
      happinessImpact: 10,
      pollutionImpact: 1,
      accent: AppTheme.purple,
    ),
    InfrastructureItem(
      emoji: '🏢',
      name: 'Office',
      costM: 1.5,
      populationImpact: 8000,
      happinessImpact: 5,
      pollutionImpact: 6,
      accent: AppTheme.blue,
    ),
    InfrastructureItem(
      emoji: '🏭',
      name: 'Factory',
      costM: 0.9,
      populationImpact: 2500,
      happinessImpact: -8,
      pollutionImpact: 20,
      accent: AppTheme.orange,
    ),
    InfrastructureItem(
      emoji: '🚉',
      name: 'Station',
      costM: 2,
      populationImpact: 4000,
      happinessImpact: 14,
      pollutionImpact: -5,
      accent: Colors.cyan,
    ),
  ];

  final List<EventItem> events = const <EventItem>[
    EventItem(
      emoji: '🎪',
      name: 'City Festival',
      description: 'Annual street celebration',
      happinessBoost: 15,
      costM: 0.5,
      accent: AppTheme.yellow,
    ),
    EventItem(
      emoji: '⚽',
      name: 'Sports Event',
      description: 'Stadium tournament',
      happinessBoost: 12,
      costM: 0.8,
      accent: AppTheme.green,
    ),
    EventItem(
      emoji: '🎵',
      name: 'Music Concert',
      description: 'Live city concert night',
      happinessBoost: 10,
      costM: 0.3,
      accent: AppTheme.purple,
    ),
    EventItem(
      emoji: '🎆',
      name: 'Fireworks Show',
      description: 'Skyline fireworks',
      happinessBoost: 8,
      costM: 0.2,
      accent: AppTheme.orange,
    ),
  ];

  double get availableBudgetM => maxBudgetM - allocatedBudgetM;

  void placeSelectedBuilding() {
    final item = selectedInfrastructure;
    if (item == null) {
      return;
    }

    allocatedBudgetM = (allocatedBudgetM + item.costM).clamp(0, maxBudgetM + 6);
    population += item.populationImpact;
    happiness = (happiness + item.happinessImpact).clamp(0, 100);
    pollution = (pollution + item.pollutionImpact).clamp(0, 100);
    buildingsBuilt += 1;
    activities.insert(0, '${item.emoji} ${item.name} placed successfully.');
  }

  void startEvent(EventItem event) {
    activeEvent = event;
    happiness = (happiness + event.happinessBoost).clamp(0, 100);
    allocatedBudgetM = (allocatedBudgetM + event.costM).clamp(0, maxBudgetM + 6);
    eventsHosted += 1;
    activities.insert(0, '${event.emoji} ${event.name} started.');
  }

  void addGreenery() {
    greenery = (greenery + 3).clamp(0, 100);
    happiness = (happiness + 5).clamp(0, 100);
    pollution = (pollution - 8).clamp(0, 100);
    activities.insert(0, '🌳 Greenery added across the city.');
  }

  void addFactory() {
    industrialZones += 1;
    happiness = (happiness - 5).clamp(0, 100);
    pollution = (pollution + 12).clamp(0, 100);
    activities.insert(0, '🏭 New factory opened in industrial zone.');
  }

  void updateCityName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      cityName = trimmed;
    }
  }

  void reset() {
    allocatedBudgetM = 5;
    happiness = 50;
    pollution = 50;
    traffic = 50;
    activities.insert(0, '🔄 City progress reset.');
  }
}
