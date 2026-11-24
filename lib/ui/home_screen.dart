import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import 'rules_screen.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNewGame});

  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    // Small phones get tighter spacing so everything still fits.
    final compact = MediaQuery.sizeOf(context).height < 700;
    return NeonBackground(
      mood: Mood.night,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, compact ? 32 : 96, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: SvgPicture.asset(
                'assets/brand/logo_typo.svg',
                semanticsLabel: 'Insider Threat',
              ),
            ),
            SizedBox(height: compact ? 24 : 44),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'A social deduction game on a compromised network.',
                textAlign: TextAlign.center,
                style: AppText.body(16,
                    weight: FontWeight.w400,
                    color: AppColors.textSoft,
                    height: 1.5),
              ),
            ),
            SizedBox(height: compact ? 16 : 24),
            const TagChip('Narrator companion', pink: true),
            const Spacer(),
            NeonButton(label: 'New game', onPressed: onNewGame),
            const SizedBox(height: 12),
            NeonButton(
              label: 'Rules',
              variant: NeonVariant.ghost,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const RulesScreen()),
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(
              width: double.infinity,
              child: Lbl('6-14 players + 1 Narrator · 20-40 min',
                  align: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
