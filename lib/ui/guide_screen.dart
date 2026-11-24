import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/guide_step.dart';
import '../theme/app_theme.dart';
import 'event_draw/event_draw_panel.dart';
import 'widgets.dart';

/// The Narrator's main screen, used for every night and day step.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key, required this.game, required this.onQuit});

  final GameController game;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final step = game.currentStep;
    final isNight = game.phase == GamePhase.night;
    final phaseLabel =
        '${isNight ? 'Night' : 'Day'} ${game.night.toString().padLeft(2, '0')}';
    final pageKey =
        '${game.phase.name}-${game.night}-${step.kind.name}-${step.stepNo}-${step.title}';

    return NeonBackground(
      mood: isNight ? Mood.night : Mood.day,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(
              children: [
                TagChip(phaseLabel),
                const SizedBox(width: 8),
                Expanded(
                  child: Lbl(
                    step.progressLabel ?? 'Step ${step.stepNo} / ${step.total}',
                    align: TextAlign.right,
                  ),
                ),
                IconButton(
                  tooltip: 'Quit the game',
                  onPressed: onQuit,
                  icon: const Icon(Icons.close, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SingleChildScrollView(
                key: ValueKey(pageKey),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _StepBody(game: game, step: step),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              children: [
                if (step.sfxName.isNotEmpty) ...[
                  _SoundPlaceholder(name: step.sfxName),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        label: 'Back',
                        variant: NeonVariant.ghost,
                        onPressed: step.canBack ? game.back : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: NeonButton(
                        label: step.primaryLabel,
                        variant: step.primaryStyle == PrimaryStyle.red
                            ? NeonVariant.red
                            : NeonVariant.primary,
                        onPressed: step.canContinue ? game.primary : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.game, required this.step});

  final GameController game;
  final GuideStep step;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[
      SegBar(current: step.stepNo, total: step.total),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Lbl(step.kicker),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: AppText.ui(34, weight: FontWeight.w700, height: 1.04),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (step.team != null) TeamDot(step.team!),
              if (step.sub.isNotEmpty)
                Text(step.sub, style: AppText.body(15, color: AppColors.textSoft)),
              if (step.tag != null) TagChip(step.tag!, danger: true),
            ],
          ),
        ],
      ),
      if (step.event != null)
        EventDrawPanel(
          key: ValueKey('draw-${game.night}-${step.event!.name}'),
          card: step.event!,
          animate: !game.eventRevealed,
          onRevealed: game.markEventRevealed,
        ),
      if (step.notice.isNotEmpty) DownList(entries: step.notice, compact: true),
      if (step.banner != null) BannerCard(text: step.banner!),
      SayCard(text: step.say),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'DO  ',
              style: AppText.mono(11, color: AppColors.blueSoft, spacing: 1.5),
            ),
            TextSpan(text: step.todo),
          ],
        ),
        style: AppText.body(14,
            weight: FontWeight.w400, color: AppColors.muted, height: 1.5),
      ),
      if (step.secret != null) SecretCard(text: step.secret!),
      if (step.report != null) DownList(entries: step.report!),
      if (step.ddos != null && step.ddos!.upcoming.isNotEmpty)
        Lbl('Next: ${step.ddos!.upcoming.join(' · ')}'),
      if (step.clock != null)
        CountdownClock(key: ValueKey(step.clock!.id), spec: step.clock!),
      if (step.tools != null)
        ToolsRow(
          spec: step.tools!,
          onRestore: game.toggleRestore,
          onKill: game.toggleKill,
        ),
      if (step.phish != null)
        PhishAnswers(
          rows: step.phish!,
          onAnswer: (id, clicked) => game.answerPhish(id, clicked: clicked),
        ),
      if (step.picker != null)
        PickerGrid(spec: step.picker!, onPick: game.pick, onNone: game.pickNone),
      for (final r in step.results) ResultRow(line: r),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          blocks[i],
        ],
      ],
    );
  }
}

/// Shows which sound belongs to this step. Audio is not wired in yet, so this
/// is deliberately not presented as a play button.
class _SoundPlaceholder extends StatelessWidget {
  const _SoundPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.graphic_eq, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(13, color: AppColors.muted),
            ),
          ),
          const Lbl('Audio coming soon'),
        ],
      );
}
