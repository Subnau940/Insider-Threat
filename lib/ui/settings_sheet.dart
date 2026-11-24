/// Sound and Narrator help settings, opened from a small button on the home,
/// setup and game screens.
library;

import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';

Future<void> showSettingsSheet(BuildContext context) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const SafeArea(child: _SettingsSheet()),
  );
}

/// Icon button that opens the settings. Its icon follows the sound state.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (context, _) {
          final s = AppSettings.instance;
          return IconButton(
            tooltip: 'Sound and Narrator settings',
            onPressed: () => showSettingsSheet(context),
            icon: Icon(
              s.gain == 0 ? Icons.volume_off_rounded : Icons.tune_rounded,
              color: AppColors.muted,
            ),
          );
        },
      );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (context, _) {
          final s = AppSettings.instance;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Settings', style: AppText.ui(28, weight: FontWeight.w700)),
                const SizedBox(height: 18),
                const Lbl('Sound'),
                const SizedBox(height: 4),
                _SwitchRow(
                  title: 'Sound',
                  sub: s.soundOn ? 'Ambience and sound effects play' : 'Everything is muted',
                  value: s.soundOn,
                  onChanged: s.setSoundOn,
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: s.soundOn ? 'Mute' : 'Unmute',
                      onPressed: () => s.setSoundOn(!s.soundOn),
                      icon: Icon(
                        s.gain == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                        color: AppColors.muted,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: s.volume,
                        onChanged: s.setVolume,
                        activeColor: s.soundOn ? AppColors.primary : AppColors.line,
                        inactiveColor: AppColors.line,
                        label: '${(s.volume * 100).round()} %',
                        divisions: 20,
                        semanticFormatterCallback: (v) => 'Volume ${(v * 100).round()} percent',
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(s.volume * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: AppText.mono(13, color: AppColors.textSoft),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Lbl('Narrator'),
                const SizedBox(height: 4),
                _SwitchRow(
                  title: 'Narrator tips',
                  sub: s.narratorTips
                      ? 'Beginner: each step explains what to do'
                      : 'Experienced: only the lines to read',
                  value: s.narratorTips,
                  onChanged: s.setNarratorTips,
                ),
              ],
            ),
          );
        },
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body(16, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub, style: AppText.body(13, color: AppColors.muted)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: const WidgetStatePropertyAll(AppColors.text),
              trackColor: WidgetStateProperty.resolveWith(
                (st) => st.contains(WidgetState.selected) ? AppColors.primary : AppColors.line,
              ),
            ),
          ],
        ),
      );
}
