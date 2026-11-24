import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/models.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.game, required this.onNewGame});

  final GameController game;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final w = game.winner!;
    final (label, line1, line2, say) = switch (w) {
      Winner.blue => (
          'Blue Team wins',
          'Network',
          'secured',
          'All attackers have been quarantined. Network secured. The Blue Team wins!',
        ),
      Winner.red => (
          'Red Team wins',
          'Network',
          'breached',
          'The last defender has fallen. Network breached. The Red Team wins!',
        ),
      Winner.purple => (
          'Purple Team wins',
          'Last machine',
          'standing',
          'Only one machine is left on the network. The double agent wins. The Purple Team wins!',
        ),
      Winner.vpn => (
          'VPN Tunnel wins',
          'Tunnel',
          'intact',
          'The last two machines are linked by a VPN tunnel. The VPN Tunnel wins!',
        ),
      Winner.outage => (
          'Nobody wins',
          'Total',
          'outage',
          'Every machine went down at the same time. Total outage. Nobody wins.',
        ),
    };
    final blueish = w == Winner.blue || w == Winner.vpn;

    return NeonBackground(
      mood: blueish ? Mood.endBlue : Mood.endRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TagChip('Game over'),
                Lbl('Day ${game.night.toString().padLeft(2, '0')}'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                Lbl(label),
                const SizedBox(height: 8),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) =>
                      (blueish ? AppColors.blueGradient : AppColors.pinkGradient)
                          .createShader(r),
                  child: Text('$line1\n$line2',
                      style: AppText.ui(46, weight: FontWeight.w700, height: 1)),
                ),
                const SizedBox(height: 14),
                SayCard(text: say),
                const SizedBox(height: 14),
                const Lbl('Roles revealed'),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 52,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: game.players.length,
                  itemBuilder: (_, i) => _RoleCell(player: game.players[i]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: NeonButton(label: 'New game', onPressed: onNewGame),
          ),
        ],
      ),
    );
  }
}

class _RoleCell extends StatelessWidget {
  const _RoleCell({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            TeamDot(player.team),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                      15,
                      weight: FontWeight.w600,
                      color: player.alive ? AppColors.text : AppColors.muted,
                      decoration:
                          player.alive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    player.role.info.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(13, weight: FontWeight.w400, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
