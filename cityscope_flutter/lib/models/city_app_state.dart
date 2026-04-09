import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'event_item.dart';
import 'infrastructure_item.dart';

class CityAppState {
  double maxBudgetM = 10;
  double capitalSpentM = 0.0;
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

  final List<BudgetDepartment> departments = <BudgetDepartment>[
    BudgetDepartment('🏥 Healthcare', 1.8, 3, Colors.red),
    BudgetDepartment('📚 Education', 1.4, 3, AppTheme.purple),
    BudgetDepartment('🚦 Transport', 1.2, 2, AppTheme.blue),
    BudgetDepartment('🌳 Environment', 0.9, 2, AppTheme.green),
    BudgetDepartment('🔒 Safety', 1.1, 2, Colors.deepOrange),
    BudgetDepartment('🏗️ Infrastructure', 2.0, 3, Colors.blueGrey),
  ];

  final List<TrafficRoad> trafficRoads = <TrafficRoad>[
    TrafficRoad(name: 'Main Avenue', congestion: 72, speed: 25, emoji: '🚗'),
    TrafficRoad(name: 'Park Boulevard', congestion: 35, speed: 55, emoji: '🚙'),
    TrafficRoad(name: 'Harbor Road', congestion: 58, speed: 38, emoji: '🚕'),
    TrafficRoad(name: 'Industrial Way', congestion: 85, speed: 18, emoji: '🚌'),
  ];

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

  double get operationsBudgetM => departments.fold<double>(0, (double s, BudgetDepartment d) => s + d.value);

  double get allocatedBudgetM => operationsBudgetM + capitalSpentM;

  double get availableBudgetM => maxBudgetM - allocatedBudgetM;

  int get healthScore => (100 - pollution * 0.4).round().clamp(0, 100);

  String get overallGrade {
    final double score = (happiness * 0.45) + ((100 - pollution) * 0.35) + ((100 - traffic) * 0.2);
    if (score >= 88) return 'A';
    if (score >= 78) return 'B+';
    if (score >= 68) return 'B';
    if (score >= 58) return 'C';
    return 'D';
  }

  void _log(String message) {
    activities.insert(0, message);
  }

  bool canAfford(double costM) => allocatedBudgetM + costM <= maxBudgetM;

  String placeSelectedBuilding() {
    final item = selectedInfrastructure;
    if (item == null) {
      return 'Select a building first.';
    }

    if (!canAfford(item.costM)) {
      return 'Insufficient budget for ${item.name}.';
    }

    capitalSpentM += item.costM;
    population += item.populationImpact;
    happiness = (happiness + item.happinessImpact).clamp(0, 100);
    pollution = (pollution + item.pollutionImpact).clamp(0, 100);
    traffic = (traffic + (item.name == 'Station' ? -8 : 2)).clamp(0, 100);
    buildingsBuilt += 1;
    _log('${item.emoji} ${item.name} placed successfully.');
    return '${item.emoji} ${item.name} placed successfully.';
  }

  String startEvent(EventItem event) {
    if (!canAfford(event.costM)) {
      return 'Not enough budget to start ${event.name}.';
    }

    activeEvent = event;
    happiness = (happiness + event.happinessBoost).clamp(0, 100);
    traffic = (traffic + 4).clamp(0, 100);
    capitalSpentM += event.costM;
    eventsHosted += 1;
    _log('${event.emoji} ${event.name} started.');
    return '${event.emoji} ${event.name} started. Happiness +${event.happinessBoost}%';
  }

  void updateDepartment(int index, double value) {
    if (index < 0 || index >= departments.length) {
      return;
    }
    departments[index].value = value;
    _recalculateFromBudget();
  }

  void _recalculateFromBudget() {
    final double healthcare = departments[0].value;
    final double education = departments[1].value;
    final double transport = departments[2].value;
    final double environment = departments[3].value;

    happiness = (52 + healthcare * 6 + education * 5 + environment * 4).round().clamp(0, 100);
    pollution = (68 - environment * 10 + industrialZones * 2).round().clamp(0, 100);
    traffic = (72 - transport * 12 + industrialZones).round().clamp(0, 100);
  }

  void addGreenery() {
    if (!canAfford(0.1)) {
      return;
    }
    capitalSpentM += 0.1;
    greenery = (greenery + 3).clamp(0, 100);
    happiness = (happiness + 5).clamp(0, 100);
    pollution = (pollution - 8).clamp(0, 100);
    _log('🌳 Greenery added across the city.');
  }

  void addFactory() {
    if (!canAfford(0.5)) {
      return;
    }
    capitalSpentM += 0.5;
    industrialZones += 1;
    happiness = (happiness - 5).clamp(0, 100);
    pollution = (pollution + 12).clamp(0, 100);
    traffic = (traffic + 6).clamp(0, 100);
    _log('🏭 New factory opened in industrial zone.');
  }

  String toggleTrafficSignal(int index) {
    if (index < 0 || index >= trafficRoads.length) {
      return 'Invalid road.';
    }
    final TrafficRoad road = trafficRoads[index];
    road.optimized = !road.optimized;
    if (road.optimized) {
      road.congestion = (road.congestion - 15).clamp(5, 95);
      road.speed = (road.speed + 10).clamp(10, 70);
      _log('🚦 ${road.name} signal optimized.');
    } else {
      road.congestion = (road.congestion + 10).clamp(5, 95);
      road.speed = (road.speed - 6).clamp(10, 70);
      _log('🚦 ${road.name} signal reverted.');
    }

    traffic = (trafficRoads.fold<int>(0, (int s, TrafficRoad r) => s + r.congestion) / trafficRoads.length).round();
    return road.optimized ? '${road.name} flow improved.' : '${road.name} flow reduced.';
  }

  int get averageSpeed {
    return (trafficRoads.fold<int>(0, (int s, TrafficRoad r) => s + r.speed) / trafficRoads.length).round();
  }

  void simulateTick() {
    // Natural city drift over time so choices have ongoing consequences.
    if (activeEvent != null) {
      happiness = (happiness - 1).clamp(0, 100);
    }
    pollution = (pollution + (industrialZones > greenery / 10 ? 1 : -1)).clamp(0, 100);
    traffic = (traffic + (industrialZones > 4 ? 1 : 0) - (departments[2].value > 1.6 ? 1 : 0)).clamp(0, 100);

    // A small monthly-like maintenance cost.
    capitalSpentM = (capitalSpentM + 0.01).clamp(0, maxBudgetM + 8);
  }

  void updateCityName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      cityName = trimmed;
    }
  }

  void reset() {
    capitalSpentM = 0.3;
    happiness = 50;
    pollution = 50;
    traffic = 50;
    greenery = 20;
    industrialZones = 3;
    for (final BudgetDepartment d in departments) {
      d.value = d.defaultValue;
    }
    for (final TrafficRoad road in trafficRoads) {
      road.reset();
    }
    _log('🔄 City progress reset.');
  }
}

class BudgetDepartment {
  BudgetDepartment(this.name, this.defaultValue, this.max, this.color) : value = defaultValue;

  final String name;
  final double defaultValue;
  final double max;
  final Color color;
  double value;
}

class TrafficRoad {
  TrafficRoad({
    required this.name,
    required this.congestion,
    required this.speed,
    required this.emoji,
  })  : _baseCongestion = congestion,
        _baseSpeed = speed;

  final String name;
  final String emoji;
  final int _baseCongestion;
  final int _baseSpeed;
  int congestion;
  int speed;
  bool optimized = false;

  void reset() {
    congestion = _baseCongestion;
    speed = _baseSpeed;
    optimized = false;
  }
}
