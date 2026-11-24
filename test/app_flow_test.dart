import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insider_threat/game/compositions.dart';
import 'package:insider_threat/game/game_controller.dart';
import 'package:insider_threat/game/guide_step.dart';
import 'package:insider_threat/game/models.dart';
import 'package:insider_threat/main.dart';
import 'package:insider_threat/theme/app_theme.dart';
import 'package:insider_threat/ui/end_screen.dart';
import 'package:insider_threat/ui/event_draw/sfx.dart';
import 'package:insider_threat/ui/guide_screen.dart';

void main() {
  setUp(() {
    AppText.useGoogleFonts = false;
    Sfx.enabled = false;
  });

  Future<void> settle(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  Future<void> run(WidgetTester t, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    await t.pumpWidget(const InsiderThreatApp());
    expect(find.text('INSIDER'), findsOneWidget);

    await t.tap(find.text('NEW GAME'));
    await settle(t);
    expect(find.text('ASSIGN 8 MORE ROLES'), findsOneWidget);

    await t.tap(find.text('DEAL AT RANDOM'));
    await settle(t);
    await t.tap(find.text('START THE GAME'));
    await settle(t);
    expect(find.text('Nightfall'), findsOneWidget);

    await t.tap(find.text('NEXT'));
    await settle(t);
    expect(find.text('Threat Hunter'), findsWidgets); // title + typed line
    expect(t.takeException(), isNull);

    // Dispose the screen so that its timers stop.
    await t.pumpWidget(const SizedBox());
  }

  testWidgets('home to first night, phone', (t) => run(t, const Size(390, 844)));
  testWidgets('home to first night, small phone',
      (t) => run(t, const Size(320, 568)));

  // Renders every step of full Expert games on a small phone: any layout
  // overflow or build error fails the test.
  for (final players in [8, 14, 18]) {
    testWidgets('full expert game renders, $players players', (t) async {
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);

      final rng = Random(players);
      final pool = recommendedComposition(players).pool..shuffle(rng);
      final game = GameController(
        players: [
          for (var i = 0; i < players; i++)
            Player(id: i, name: 'Maximilienne $i', role: pool[i]),
        ],
        expert: true,
        random: rng,
      );
      await t.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: ListenableBuilder(
          listenable: game,
          builder: (_, _) => game.phase == GamePhase.end
              ? EndScreen(game: game, onNewGame: () {})
              : GuideScreen(game: game, onQuit: () {}),
        ),
      ));

      var guard = 0;
      while (game.phase != GamePhase.end && guard++ < 600) {
        final s = game.currentStep;
        for (final row in s.phish ?? const <PhishRow>[]) {
          game.answerPhish(row.id, clicked: rng.nextBool());
        }
        final picker = s.picker;
        if (picker != null) {
          final free = picker.tiles.where((x) => !x.locked).toList();
          final wanted = s.kind == StepKind.engineer ? 2 : picker.max;
          if (s.kind == StepKind.vote) {
            final foe = game.alivePlayers.where((p) => p.team != Team.blue);
            game.pick(foe.isNotEmpty ? foe.first.id : free.first.id);
          } else if (free.isEmpty) {
            game.pickNone();
          } else {
            for (final x in free.take(wanted)) {
              game.pick(x.id);
            }
          }
        }
        await t.pump();
        expect(t.takeException(), isNull, reason: s.kind.name);
        game.primary();
        await t.pump(const Duration(milliseconds: 250));
        expect(t.takeException(), isNull, reason: s.kind.name);
      }
      expect(game.phase, GamePhase.end);
      await t.pump(const Duration(milliseconds: 250));
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 2));
    });
  }
}
