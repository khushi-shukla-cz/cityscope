import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/city_app_state.dart';
import '../models/event_item.dart';
import '../models/infrastructure_item.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_title.dart';
import '../widgets/simple_charts.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final CityAppState _state = CityAppState();
  final TextEditingController _cityController = TextEditingController(text: 'Nova City');
  late Timer _ticker;
  late Timer _simTimer;

  bool _showSplash = true;
  bool _showHomeMap = true;
  int _currentIndex = 0;
  String _nowTime = DateFormat.jm().format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nowTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
    _simTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _showSplash) {
        return;
      }
      setState(_state.simulateTick);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _simTimer.cancel();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return _SplashScreen(
        onBuildCity: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool rail = constraints.maxWidth >= 980;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppTheme.bgStart, AppTheme.bgEnd],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Row(
                children: <Widget>[
                  if (rail) _buildRail(),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _buildTopBar(rail),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _buildScreen(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: rail ? null : _buildMobileNav(),
          ),
        );
      },
    );
  }

  Widget _buildMobileNav() {
    Widget navButton({required int index}) {
      final NavData nav = _destinations[index];
      final bool active = _currentIndex == index;
      return Expanded(
        child: TextButton(
          onPressed: () => setState(() => _currentIndex = index),
          style: TextButton.styleFrom(foregroundColor: active ? AppTheme.green : AppTheme.textDim),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(nav.emoji),
              Text(nav.label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: const Color(0xFF131321),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            navButton(index: 0),
            navButton(index: 1),
            navButton(index: 3),
            navButton(index: 8),
            IconButton(
              onPressed: _showSectionPicker,
              icon: const Icon(Icons.grid_view_rounded, color: AppTheme.text),
              tooltip: 'All sections',
            ),
          ],
        ),
      ),
    );
  }

  void _showSectionPicker() {
    const Set<int> quickNavIndexes = <int>{0, 1, 3, 8};
    final List<int> moreIndexes = List<int>.generate(_destinations.length, (int i) => i)
        .where((int i) => !quickNavIndexes.contains(i))
        .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: moreIndexes.length,
            itemBuilder: (BuildContext context, int index) {
              final int destinationIndex = moreIndexes[index];
              final NavData nav = _destinations[destinationIndex];
              return ListTile(
                leading: Text(nav.emoji, style: const TextStyle(fontSize: 20)),
                title: Text(nav.title),
                subtitle: Text(nav.label),
                selected: _currentIndex == destinationIndex,
                onTap: () {
                  setState(() => _currentIndex = destinationIndex);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int value) => setState(() => _currentIndex = value),
      labelType: NavigationRailLabelType.all,
      backgroundColor: const Color(0xE60F0F1C),
      indicatorColor: AppTheme.green.withValues(alpha: 0.18),
      leading: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'CS',
          style: GoogleFonts.orbitron(
            color: AppTheme.green,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      destinations: _destinations
          .map(
            (NavData nav) => NavigationRailDestination(
              icon: Text(nav.emoji),
              selectedIcon: Text(nav.emoji),
              label: Text(nav.label),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTopBar(bool railLayout) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 680;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (!railLayout)
                    IconButton(
                      onPressed: _showSectionPicker,
                      icon: const Icon(Icons.menu_rounded),
                      tooltip: 'All sections',
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _destinations[_currentIndex].title,
                          style: GoogleFonts.orbitron(fontWeight: FontWeight.w700, fontSize: compact ? 16 : 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back, Mayor',
                          style: TextStyle(color: AppTheme.textDim.withValues(alpha: 0.9), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4E2C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.green.withValues(alpha: 0.7)),
                    ),
                    child: Text('🏙️ ${_state.cityName}', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(_nowTime, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.textDim)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return _homeScreen();
      case 1:
        return _infraScreen();
      case 2:
        return _populationScreen();
      case 3:
        return _budgetScreen();
      case 4:
        return _pollutionScreen();
      case 5:
        return _trafficScreen();
      case 6:
        return _eventsScreen();
      case 7:
        return _reportsScreen();
      case 8:
        return _profileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _homeScreen() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 760;
        return ListView(
          children: <Widget>[
            compact
                ? SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _homeKpis()
                          .map((Widget card) => SizedBox(width: 235, child: Padding(padding: const EdgeInsets.only(right: 10), child: card)))
                          .toList(),
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _homeKpis().map((Widget card) => SizedBox(width: 220, child: card)).toList(),
                  ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(child: SectionTitle('City Map')),
                  TextButton.icon(
                    onPressed: () => setState(() => _showHomeMap = !_showHomeMap),
                    icon: Icon(_showHomeMap ? Icons.expand_less : Icons.expand_more, size: 16),
                    label: Text(_showHomeMap ? 'Collapse' : 'Expand'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_showHomeMap)
                Container(
                  height: compact ? 220 : 280,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF0A1628), Color(0xFF0D1F3C), Color(0xFF101428)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                      ..._mapMarkers(),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints inner) {
            final bool twoCol = inner.maxWidth > 860;
            if (!twoCol) {
              return Column(
                children: <Widget>[
                  _activityCard(),
                  const SizedBox(height: 14),
                  _cityHealthCard(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _activityCard()),
                const SizedBox(width: 14),
                Expanded(child: _cityHealthCard()),
              ],
            );
          },
        ),
          ],
        );
      },
    );
  }

  List<Widget> _homeKpis() {
    return <Widget>[
      KpiCard(
        icon: '💰',
        label: 'Budget',
        value: '\$${_state.availableBudgetM.toStringAsFixed(1)}M',
        progress: (_state.availableBudgetM / _state.maxBudgetM).clamp(0, 1),
        color: AppTheme.green,
        delta: 'Weekly stability',
        onTap: () => setState(() => _currentIndex = 3),
      ),
      KpiCard(
        icon: '😊',
        label: 'Happiness',
        value: '${_state.happiness}%',
        progress: _state.happiness / 100,
        color: AppTheme.yellow,
        delta: 'Steady growth',
        onTap: () => setState(() => _currentIndex = 6),
      ),
      KpiCard(
        icon: '🌫️',
        label: 'Pollution',
        value: '${_state.pollution}%',
        progress: _state.pollution / 100,
        color: AppTheme.orange,
        delta: 'Track this daily',
        onTap: () => setState(() => _currentIndex = 4),
      ),
      KpiCard(
        icon: '🚗',
        label: 'Traffic',
        value: '${_state.traffic}%',
        progress: _state.traffic / 100,
        color: AppTheme.blue,
        delta: 'Moderate flow',
        onTap: () => setState(() => _currentIndex = 5),
      ),
    ];
  }

  List<Widget> _mapMarkers() {
    final List<Widget> markers = <Widget>[];
    const data = <Map<String, dynamic>>[
      <String, dynamic>{'emoji': '🏢', 'name': 'City Hall', 'x': 0.15, 'y': 0.16},
      <String, dynamic>{'emoji': '🏥', 'name': 'Hospital', 'x': 0.45, 'y': 0.12},
      <String, dynamic>{'emoji': '🌳', 'name': 'Central Park', 'x': 0.72, 'y': 0.2},
      <String, dynamic>{'emoji': '🏫', 'name': 'Academy', 'x': 0.24, 'y': 0.5},
      <String, dynamic>{'emoji': '🏭', 'name': 'Steel Works', 'x': 0.62, 'y': 0.54},
      <String, dynamic>{'emoji': '⚓', 'name': 'Harbor', 'x': 0.82, 'y': 0.75},
    ];

    for (final Map<String, dynamic> marker in data) {
      markers.add(
        Align(
          alignment: Alignment((marker['x'] as double) * 2 - 1, (marker['y'] as double) * 2 - 1),
          child: Tooltip(
            message: marker['name'].toString(),
            child: Text(marker['emoji'].toString(), style: const TextStyle(fontSize: 28)),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _activityCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('Activity Feed'),
          const SizedBox(height: 12),
          ..._state.activities.take(6).map(
                (String e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('•', style: TextStyle(color: AppTheme.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e, style: const TextStyle(color: AppTheme.textDim))),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _cityHealthCard() {
    Widget line(String name, int value, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(name)),
                Text('$value%', style: GoogleFonts.jetBrainsMono(color: color)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: value / 100, color: color, backgroundColor: Colors.white12),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('City Health'),
          const SizedBox(height: 12),
          line('😊 Happiness', _state.happiness, AppTheme.yellow),
          line('🏥 Healthcare', 81, AppTheme.blue),
          line('📚 Education', 67, AppTheme.purple),
          line('🌳 Green Score', 58, AppTheme.green),
          const Divider(color: AppTheme.cardBorder),
          Text('Population', style: TextStyle(color: AppTheme.textDim.withValues(alpha: 0.9))),
          Text(NumberFormat.compact().format(_state.population), style: GoogleFonts.orbitron(fontSize: 30, color: AppTheme.blue)),
        ],
      ),
    );
  }

  Widget _infraScreen() {
    return ListView(
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Select Building Type'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _state.infrastructureItems.map((InfrastructureItem item) {
                  final bool selected = item == _state.selectedInfrastructure;
                  return InkWell(
                    onTap: () => setState(() => _state.selectedInfrastructure = item),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 170,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? item.accent.withValues(alpha: 0.15) : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? item.accent : AppTheme.cardBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(item.costLabel, style: GoogleFonts.jetBrainsMono(color: AppTheme.orange, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            'Pop ${item.populationImpact >= 0 ? '+' : ''}${item.populationImpact}',
                            style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Placement Zone'),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    final String message = _state.placeSelectedBuilding();
                    _snack(message);
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _state.selectedInfrastructure == null ? AppTheme.cardBorder : AppTheme.green,
                      style: BorderStyle.solid,
                    ),
                    color: _state.selectedInfrastructure == null
                        ? AppTheme.cardBg
                        : AppTheme.green.withValues(alpha: 0.08),
                  ),
                  child: Center(
                    child: Text(
                      _state.selectedInfrastructure == null
                          ? '📍 Select a building above then tap to place'
                          : '${_state.selectedInfrastructure!.emoji} Tap to place ${_state.selectedInfrastructure!.name}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _populationScreen() {
    final List<double> data = <double>[108, 110, 112, 113, 115, 117, 118, 120, 121, 122, 123, 124.8];
    return ListView(
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Demographics'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: const <Widget>[
                  _InfoTag(label: 'Youth', value: '28%', color: AppTheme.green),
                  _InfoTag(label: 'Adults', value: '45%', color: AppTheme.blue),
                  _InfoTag(label: 'Seniors', value: '18%', color: AppTheme.orange),
                  _InfoTag(label: 'Other', value: '9%', color: AppTheme.purple),
                ],
              ),
              const SizedBox(height: 14),
              const MiniPieChart(
                values: <double>[28, 45, 18, 9],
                colors: <Color>[AppTheme.green, AppTheme.blue, AppTheme.orange, AppTheme.purple],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Growth Trend'),
              const SizedBox(height: 10),
              const MiniLineChart(values: <double>[108, 110, 112, 113, 115, 117, 118, 120, 121, 122, 123, 124.8], color: AppTheme.blue),
              const SizedBox(height: 8),
              Text(
                'Current population: ${NumberFormat.decimalPattern().format(_state.population)}',
                style: const TextStyle(color: AppTheme.textDim),
              ),
              Text('Data points: ${data.length} months', style: const TextStyle(color: AppTheme.textDim, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _budgetScreen() {
    return ListView(
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Budget Allocation Simulator'),
              const SizedBox(height: 10),
              Text(
                'Allocated: \$${_state.allocatedBudgetM.toStringAsFixed(2)}M / \$${_state.maxBudgetM.toStringAsFixed(2)}M',
                style: GoogleFonts.jetBrainsMono(color: AppTheme.green),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_state.allocatedBudgetM / _state.maxBudgetM).clamp(0, 1),
                  minHeight: 10,
                  color: _state.allocatedBudgetM <= _state.maxBudgetM ? AppTheme.green : AppTheme.orange,
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: 14),
              ..._state.departments.asMap().entries.map(
                (MapEntry<int, BudgetDepartment> entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: Text(entry.value.name)),
                          Text('\$${entry.value.value.toStringAsFixed(1)}M', style: GoogleFonts.jetBrainsMono(color: entry.value.color)),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: entry.value.color,
                          thumbColor: entry.value.color,
                          inactiveTrackColor: Colors.white10,
                        ),
                        child: Slider(
                          value: entry.value.value,
                          min: 0,
                          max: entry.value.max,
                          onChanged: (double v) {
                            setState(() {
                              _state.updateDepartment(entry.key, v);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionTitle('Breakdown'),
              SizedBox(height: 10),
              Center(
                child: MiniPieChart(
                  values: <double>[1.8, 1.4, 1.2, 0.9, 1.1, 2.0],
                  colors: <Color>[Colors.red, AppTheme.purple, AppTheme.blue, AppTheme.green, Colors.deepOrange, Colors.blueGrey],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pollutionScreen() {
    final int aqi = (_state.pollution * 1.8).round();
    return ListView(
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Pollution Sources'),
              const SizedBox(height: 10),
              _pollutionBar('🏭 Industrial', _state.pollution.clamp(0, 100).toDouble(), AppTheme.orange),
              _pollutionBar('🚗 Transport', 28, Colors.deepOrangeAccent),
              _pollutionBar('⚡ Energy', 18, AppTheme.yellow),
              _pollutionBar('🗑️ Waste', 9, Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('City Atmosphere'),
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _state.pollution > 60
                      ? AppTheme.orange.withValues(alpha: 0.2)
                      : _state.pollution > 35
                          ? AppTheme.yellow.withValues(alpha: 0.12)
                          : AppTheme.green.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    _state.pollution > 60
                        ? '😷'
                        : _state.pollution > 35
                            ? '🌆'
                            : '🌇',
                    style: const TextStyle(fontSize: 52),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        if (!_state.canAfford(0.1)) {
                          _snack('Not enough budget to add greenery.');
                          return;
                        }
                        _state.addGreenery();
                        _snack('Greenery added. Pollution reduced.');
                      }),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white),
                      child: const Text('🌳 Add Greenery'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        if (!_state.canAfford(0.5)) {
                          _snack('Not enough budget to add factory.');
                          return;
                        }
                        _state.addFactory();
                        _snack('Factory added. Watch pollution and traffic.');
                      }),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange),
                      child: const Text('🏭 Add Factory'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _metricBox('Air Quality Index', '$aqi', AppTheme.yellow),
                  _metricBox('Green Coverage', '${_state.greenery}%', AppTheme.green),
                  _metricBox('Industrial Zones', '${_state.industrialZones}', AppTheme.orange),
                  _metricBox('Health Score', '${_state.healthScore}', AppTheme.blue),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pollutionBar(String name, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(name)),
              Text('${value.round()}%', style: GoogleFonts.jetBrainsMono(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: value / 100, color: color, minHeight: 8, backgroundColor: Colors.white10),
          ),
        ],
      ),
    );
  }

  Widget _trafficScreen() {
    return ListView(
      children: <Widget>[
        GlassCard(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _metricBox('Avg Speed', '${_state.averageSpeed} km/h', AppTheme.blue),
              _metricBox('Traffic Load', '${_state.traffic}%', AppTheme.orange),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Road Conditions'),
              const SizedBox(height: 10),
              ..._state.trafficRoads.asMap().entries.map(
                (MapEntry<int, TrafficRoad> entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        final String message = _state.toggleTrafficSignal(entry.key);
                        _snack(message);
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(entry.value.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(entry.value.name),
                              Text(
                                'Congestion ${entry.value.congestion}% • Speed ${entry.value.speed} km/h',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textDim),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: entry.value.optimized ? AppTheme.green : AppTheme.orange,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: (entry.value.optimized ? AppTheme.green : AppTheme.orange).withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eventsScreen() {
    return ListView(
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Choose Event'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _state.events.map((EventItem event) {
                  final bool active = _state.activeEvent == event;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        final String message = _state.startEvent(event);
                        _snack(message);
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 210,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: active ? event.accent.withValues(alpha: 0.16) : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: active ? event.accent : AppTheme.cardBorder, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(event.emoji, style: const TextStyle(fontSize: 30)),
                          const SizedBox(height: 8),
                          Text(event.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(event.description, style: const TextStyle(color: AppTheme.textDim, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(
                            'Happiness +${event.happinessBoost}% • \$${event.costM.toStringAsFixed(1)}M',
                            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.yellow),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Row(
            children: <Widget>[
              Text('${_state.happiness}%', style: GoogleFonts.orbitron(fontSize: 42, color: AppTheme.yellow, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _state.happiness / 100,
                    minHeight: 24,
                    color: AppTheme.yellow,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportsScreen() {
    return ListView(
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _reportKpi('Overall Grade', _state.overallGrade, AppTheme.green),
            _reportKpi('Population', NumberFormat.compact().format(_state.population), AppTheme.blue),
            _reportKpi('Happiness', '${_state.happiness}%', AppTheme.yellow),
            _reportKpi('Pollution', '${_state.pollution}%', AppTheme.orange),
          ],
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Monthly Progress'),
              const SizedBox(height: 10),
              MiniLineChart(
                values: <double>[
                  (_state.happiness - 12).toDouble(),
                  (_state.happiness - 8).toDouble(),
                  (_state.happiness - 5).toDouble(),
                  (_state.happiness - 2).toDouble(),
                  _state.happiness.toDouble(),
                ],
                color: AppTheme.yellow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportKpi(String label, String value, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: <Widget>[
          Text(value, style: GoogleFonts.orbitron(fontSize: 28, color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textDim, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _profileScreen() {
    final Duration playtime = DateTime.now().difference(_state.startTime);

    return ListView(
      children: <Widget>[
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Mayor Identity'),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cardBg,
                      border: Border.all(color: AppTheme.green),
                    ),
                    child: const Center(child: Text('👨‍💼', style: TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Khushi Shukla', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text('${_state.cityName} • Est. 2024', style: const TextStyle(color: AppTheme.textDim, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _cityController,
                onChanged: (String value) => setState(() => _state.updateCityName(value)),
                decoration: InputDecoration(
                  labelText: 'City Name',
                  labelStyle: const TextStyle(color: AppTheme.textDim),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _snack('Profile saved.'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white),
                      child: const Text('Save Profile'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(_state.reset);
                        _snack('City reset complete.');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange),
                      child: const Text('Reset City'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('City Statistics'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _metricBox('Buildings Built', '${_state.buildingsBuilt}', AppTheme.blue),
                  _metricBox('Events Hosted', '${_state.eventsHosted}', AppTheme.yellow),
                  _metricBox('Play Time', '${playtime.inHours}h ${playtime.inMinutes.remainder(60)}m', AppTheme.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppTheme.textDim, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.orbitron(fontSize: 22, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _snack(String message) {
    final String lower = message.toLowerCase();
    final bool isBudgetWarning =
        lower.contains('insufficient budget') || lower.contains('not enough budget') || lower.contains('not enough');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            if (isBudgetWarning)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              ),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isBudgetWarning ? const Color(0xFF9C2F1A) : const Color(0xFF25253A),
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint major = Paint()
      ..color = AppTheme.blue.withValues(alpha: 0.14)
      ..strokeWidth = 1;
    final Paint minor = Paint()
      ..color = AppTheme.blue.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('$label ', style: const TextStyle(fontSize: 12)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen({required this.onBuildCity});

  final VoidCallback onBuildCity;

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                return CustomPaint(painter: _StarFieldPainter(progress: _controller.value));
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ShaderMask(
                  shaderCallback: (Rect bounds) => const LinearGradient(
                    colors: <Color>[AppTheme.green, AppTheme.blue, AppTheme.purple],
                  ).createShader(bounds),
                  child: Text(
                    'CityScope',
                    style: GoogleFonts.orbitron(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Urban Planning Simulator',
                  style: GoogleFonts.exo2(letterSpacing: 2, color: AppTheme.textDim),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: widget.onBuildCity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('🏙️ Build Your City'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final Uri uri = Uri.parse('https://docs.flutter.dev');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.blue,
                        side: const BorderSide(color: AppTheme.blue),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('📖 Tutorial'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(24, (int i) {
                  final double h = 40 + ((i * 31) % 90).toDouble();
                  return Container(
                    width: 10,
                    height: h,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[Color(0xFF1A1A3E), Color(0xFF2A2A5E)],
                      ),
                      border: Border.all(color: AppTheme.blue.withValues(alpha: 0.25)),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  _StarFieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    for (int i = 0; i < 160; i++) {
      final double x = ((i * 73) % 1000) / 1000 * size.width;
      final double y = ((i * 97) % 1000) / 1000 * size.height;
      final double twinkle = 0.3 + 0.7 * (0.5 + 0.5 * math.sin((progress * 8) + i));
      p.color = Colors.white.withValues(alpha: twinkle.clamp(0.2, 1.0));
      canvas.drawCircle(Offset(x, y), i % 9 == 0 ? 1.9 : 1.2, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class NavData {
  const NavData(this.emoji, this.label, this.title);

  final String emoji;
  final String label;
  final String title;
}

const List<NavData> _destinations = <NavData>[
  NavData('🏠', 'Home', 'City Dashboard'),
  NavData('🏗️', 'Build', 'Add Infrastructure'),
  NavData('👥', 'People', 'Population Insights'),
  NavData('💰', 'Budget', 'Budget Simulator'),
  NavData('🌿', 'Eco', 'Pollution & Health'),
  NavData('🚦', 'Traffic', 'Traffic Flow'),
  NavData('🎉', 'Events', 'Event Planner'),
  NavData('📊', 'Reports', 'Reports & Summary'),
  NavData('👤', 'Profile', 'Profile & Settings'),
];
