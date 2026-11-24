import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../game/models.dart';
import '../theme/app_theme.dart';
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
            const TagChip('Narrator companion'),
            const Spacer(),
            NeonButton(label: 'New game', onPressed: onNewGame),
            const SizedBox(height: 12),
            NeonButton(
              label: 'Rules',
              variant: NeonVariant.ghost,
              onPressed: () => showRolesSheet(context),
            ),
            const SizedBox(height: 14),
            const SizedBox(
              width: double.infinity,
              child: Lbl('6–14 players + 1 Narrator · 20–40 min',
                  align: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

void showRolesSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SizedBox(
      height: MediaQuery.sizeOf(ctx).height * .86,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text('Roles', style: AppText.ui(32, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          for (final id in roleDisplayOrder)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TeamDot(id.info.team),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(id.info.name,
                            style: AppText.ui(18, weight: FontWeight.w700)),
                      ),
                      Lbl(id.info.character),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(id.info.power,
                      style: AppText.body(14,
                          weight: FontWeight.w400,
                          color: AppColors.textSoft,
                          height: 1.45)),
                  const SizedBox(height: 8),
                  Lbl('Wakes: ${id.info.wakes}'),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
