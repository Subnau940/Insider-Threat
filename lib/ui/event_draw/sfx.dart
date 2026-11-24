import 'package:audioplayers/audioplayers.dart';

import '../../game/events.dart';

/// Sound effects of the Event draw. Files live in assets/sfx/, named after the
/// enum values.
enum SfxId { alert, spawn, glitch, flip, revealBlue, revealRed, revealChaos, out }

extension RevealSfx on EventSide {
  SfxId get revealSfx => switch (this) {
        EventSide.blue => SfxId.revealBlue,
        EventSide.red => SfxId.revealRed,
        EventSide.chaos => SfxId.revealChaos,
      };
}

class Sfx {
  Sfx._();

  static final instance = Sfx._();

  /// Tests turn this off: there is no audio plugin in the test environment.
  static bool enabled = true;

  final Map<SfxId, AudioPlayer> _players = {};
  bool _loading = false;

  /// Preloads every sound so the first play has no delay.
  Future<void> preload() async {
    if (!enabled || _loading) return;
    _loading = true;
    try {
      await AudioCache.instance
          .loadAll([for (final id in SfxId.values) 'sfx/${id.name}.wav']);
    } catch (_) {
      // Sounds are a bonus: never let them break the game.
    }
  }

  void play(SfxId id, {double volume = 0.9}) {
    if (!enabled) return;
    try {
      final player = _players.putIfAbsent(id, AudioPlayer.new);
      player
          .play(AssetSource('sfx/${id.name}.wav'),
              volume: volume, mode: PlayerMode.lowLatency)
          .catchError((_) {});
    } catch (_) {
      // Same as above: a sound error must not stop the animation.
    }
  }
}
