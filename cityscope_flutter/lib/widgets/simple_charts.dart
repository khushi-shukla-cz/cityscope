import 'dart:math' as math;

import 'package:flutter/material.dart';

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({super.key, required this.values, this.color = Colors.blue});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _MiniLineChartPainter(values: values, color: color),
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  _MiniLineChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final range = (maxVal - minVal).abs() < 0.01 ? 1.0 : (maxVal - minVal);

    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..shader = LinearGradient(
        colors: <Color>[color.withValues(alpha: 0.3), color.withValues(alpha: 0.02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final grid = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.1 + (i * 0.25));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minVal) / range) * (size.height - 12) - 6;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath
          ..moveTo(x, size.height)
          ..lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class MiniPieChart extends StatelessWidget {
  const MiniPieChart({super.key, required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _MiniPiePainter(values: values, colors: colors),
    );
  }
}

class _MiniPiePainter extends CustomPainter {
  _MiniPiePainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final total = values.fold<double>(0, (double s, double v) => s + v);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;
    var start = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * math.pi;
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, paint);
      start += sweep;
    }

    canvas.drawCircle(center, radius * 0.48, Paint()..color = const Color(0xFF1E1E2F));
  }

  @override
  bool shouldRepaint(covariant _MiniPiePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
