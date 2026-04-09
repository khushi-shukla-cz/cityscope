import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 12,
            letterSpacing: 1.4,
            color: AppTheme.textDim,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(
            color: AppTheme.cardBorder,
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}
