import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_theme.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.delta,
    this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final double progress;
  final Color color;
  final String delta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                letterSpacing: 1,
                color: AppTheme.textDim,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 22,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 5,
                backgroundColor: Colors.white12,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              delta,
              style: const TextStyle(fontSize: 11, color: AppTheme.textDim),
            ),
          ],
        ),
      ),
    );
  }
}
