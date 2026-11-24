import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../app_settings.dart';
import '../../game/events.dart';

/// Sound effects of the app. Files live in assets/sfx/, named after the enum
/// values.
enum SfxId {
  alert,
  spawn,
  glitch,
  flip,
  revealBlue,
  revealRed,
  revealChaos,
  out,
  timerWarning,
  nightAmbience,
  dayAmbience,
  ddos,
  c2ServerDown;

  String get file => long ? 'sfx/$name.mp3' : 'sfx/$name.wav';

  /// Long sounds need the full media player so they can be paused and stopped.
  bool get long => const {
    timerWarning,
    nightAmbience,
    dayAmbience,
    ddos,
    c2ServerDown,
  }.contains(this);
}

/// Events with a sound of their own, played instead of the side's reveal.
extension EventSfx on EventCard {
  SfxId? get revealSfx => switch (this) {
    EventCard.ddos => SfxId.ddos,
    EventCard.c2ServerDown => SfxId.c2ServerDown,
    _ => null,
  };
}

extension RevealSfx on EventSide {
  SfxId get revealSfx => switch (this) {
    EventSide.blue => SfxId.revealBlue,
    EventSide.red => SfxId.revealRed,
    EventSide.chaos => SfxId.revealChaos,
  };
}

class Sfx {
  Sfx._() {
    // Volume or mute changed in the settings: apply it to the sounds that are
    // playing right now (the ambience loops).
    AppSettings.instance.addListener(_applyGain);
  }

  static final instance = Sfx._();

  /// Each sound's own level, before the master volume.
  final Map<SfxId, double> _base = {};

  double get _gain => AppSettings.instance.gain;

  void _applyGain() {
    for (final id in _active) {
      if (_fades.containsKey(id)) continue; // fading out: leave it alone
      _safe(id, (p) => p.setVolume((_base[id] ?? 1) * _gain));
    }
  }

  /// Tests turn this off: there is no audio plugin in the test environment.
  static bool enabled = true;

  final Map<SfxId, AudioPlayer> _players = {};
  bool _loading = false;

  /// Preloads every sound so the first play has no delay.
  Future<void> preload() async {
    if (!enabled || _loading) return;
    _loading = true;
    try {
      await AudioCache.instance.loadAll([
        for (final id in SfxId.values) id.file,
      ]);
    } catch (_) {
      // Sounds are a bonus: never let them break the game.
    }
  }

  void play(SfxId id, {double volume = 0.9}) {
    if (!enabled) return;
    _fades.remove(id)?.cancel();
    if (id.long) _active.add(id);
    _base[id] = volume;
    try {
      _player(id)
          .play(
            AssetSource(id.file),
            volume: volume * _gain,
            mode: id.long ? PlayerMode.mediaPlayer : PlayerMode.lowLatency,
          )
          .catchError((_) {});
    } catch (_) {
      // Same as above: a sound error must not stop the animation.
    }
  }

  final Set<SfxId> _active = {};
  final Map<SfxId, Timer> _fades = {};

  /// Plays [id] in a loop until [fadeOut]. Calling it again while it loops
  /// does nothing, so it can be called on every rebuild.
  void loop(SfxId id, {double volume = 0.6}) {
    if (!enabled) return;
    final fade = _fades.remove(id);
    fade?.cancel();
    _base[id] = volume;
    // Already looping, or still fading out: keep playing, back at full volume.
    if (!_active.add(id) || fade != null) {
      _safe(id, (p) => p.setVolume(volume * _gain));
      return;
    }
    try {
      final player = _player(id);
      player
          .setReleaseMode(ReleaseMode.loop)
          .then(
            (_) => player.play(
              AssetSource(id.file),
              volume: volume * _gain,
              mode: PlayerMode.mediaPlayer,
            ),
          )
          .catchError((_) {});
    } catch (_) {}
  }

  /// Lowers a long sound to silence over [duration], then stops it.
  void fadeOut(
    SfxId id, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    if (!_active.remove(id)) return;
    final player = _players[id];
    if (player == null) return;
    const steps = 15;
    final start = player.volume;
    var i = 0;
    _fades.remove(id)?.cancel();
    _fades[id] = Timer.periodic(duration ~/ steps, (t) {
      i++;
      if (i >= steps) {
        t.cancel();
        _fades.remove(id);
        _safe(id, (p) => p.stop());
      } else {
        _safe(id, (p) => p.setVolume(start * (1 - i / steps)));
      }
    });
  }

  void pause(SfxId id) => _safe(id, (p) => p.pause());

  void resume(SfxId id) => _safe(id, (p) => p.resume());

  void stop(SfxId id) {
    _active.remove(id);
    _safe(id, (p) => p.stop());
  }

  AudioPlayer _player(SfxId id) => _players.putIfAbsent(id, AudioPlayer.new);

  void _safe(SfxId id, Future<void> Function(AudioPlayer) action) {
    if (!enabled || !_players.containsKey(id)) return;
    try {
      action(_players[id]!).catchError((_) {});
    } catch (_) {}
  }
}
