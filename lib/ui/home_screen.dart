import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNewGame});

  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      mood: Mood.night,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INSIDER',
                      style: AppText.ui(70, weight: FontWeight.w700, height: .96)),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (r) => const LinearGradient(
                      colors: [AppColors.red, Color(0xFFB26BFF)],
                    ).createShader(r),
                    child: Text('THREAT',
                        style:
                            AppText.ui(70, weight: FontWeight.w700, height: .96)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'A social deduction game on a compromised network.',
                style: AppText.ui(16,
                    weight: FontWeight.w400,
                    color: AppColors.textSoft,
                    height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
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
              child: Lbl('8–18 players + 1 Narrator · 30–60 min',
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
                      style: AppText.ui(14,
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
