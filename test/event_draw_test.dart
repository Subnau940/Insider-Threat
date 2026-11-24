import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insider_threat/game/events.dart';
import 'package:insider_threat/game/game_controller.dart';
import 'package:insider_threat/game/models.dart';
import 'package:insider_threat/theme/app_theme.dart';
import 'package:insider_threat/ui/event_draw/event_draw_panel.dart';
import 'package:insider_threat/ui/event_draw/sfx.dart';

void main() {
  setUp(() {
    AppText.useGoogleFonts = false;
    Sfx.enabled = false;
  });

  Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            disableAnimations: reduceMotion,
          ),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  Future<void> runFor(WidgetTester t, Duration d) async {
    for (var e = Duration.zero; e < d; e += const Duration(milliseconds: 50)) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('plays the whole draw, then reveals the card', (t) async {
    var revealed = 0;
    await t.pumpWidget(host(EventDrawPanel(
      card: EventCard.securityAudit,
      animate: true,
      onRevealed: () => revealed++,
    )));
    // mid-animation: the title is not decoded yet
    await runFor(t, const Duration(milliseconds: 600));
    expect(find.text('SECURITY AUDIT'), findsNothing);
    expect(revealed, 0);

    await runFor(t, const Duration(seconds: 5));
    expect(find.text('SECURITY AUDIT'), findsOneWidget);
    expect(find.text('Replay the draw'), findsOneWidget);
    expect(revealed, 1);
    expect(t.takeException(), isNull);
  });

  testWidgets('an already revealed card shows at once', (t) async {
    var revealed = 0;
    await t.pumpWidget(host(EventDrawPanel(
      card: EventCard.ddos,
      animate: false,
      onRevealed: () => revealed++,
    )));
    await t.pump();
    expect(find.text('DDOS'), findsOneWidget);
    expect(revealed, 0);
  });

  testWidgets('reduced motion still reveals the card quickly', (t) async {
    var revealed = 0;
    await t.pumpWidget(host(
      EventDrawPanel(
        card: EventCard.honeypot,
        animate: true,
        onRevealed: () => revealed++,
      ),
      reduceMotion: true,
    ));
    await runFor(t, const Duration(seconds: 1));
    expect(find.text('HONEYPOT'), findsOneWidget);
    expect(revealed, 1);
  });

  testWidgets('replay runs the draw again', (t) async {
    var revealed = 0;
    await t.pumpWidget(host(EventDrawPanel(
      card: EventCard.zeroDay,
      animate: true,
      onRevealed: () => revealed++,
    )));
    await runFor(t, const Duration(seconds: 5));
    await t.tap(find.text('Replay the draw'));
    await runFor(t, const Duration(milliseconds: 300));
    expect(find.text('ZERO-DAY'), findsNothing);
    await runFor(t, const Duration(seconds: 5));
    expect(find.text('ZERO-DAY'), findsOneWidget);
    expect(revealed, 2);
  });

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('every card renders at ${size.width.toInt()} px', (t) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      for (final card in EventCard.values) {
        await t.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EventDrawPanel(
                key: ValueKey(card),
                card: card,
                animate: false,
              ),
            ),
          ),
        ));
        await t.pump();
        expect(t.takeException(), isNull, reason: card.name);
      }
    });
  }

  test('the card is revealed once per day', () {
    const roles = [
      RoleId.red,
      RoleId.red,
      RoleId.threatHunter,
      RoleId.incidentResponder,
      RoleId.deadMansSwitch,
      RoleId.defender,
      RoleId.defender,
      RoleId.defender,
    ];
    final c = GameController(
      players: [
        for (var i = 0; i < roles.length; i++)
          Player(id: i, name: 'P$i', role: roles[i]),
      ],
      expert: true,
      random: Random(1),
    );
    expect(c.eventRevealed, isFalse);
    c.debugSetTodayEvent(EventCard.ddos);
    expect(c.eventRevealed, isFalse);
    c.markEventRevealed();
    expect(c.eventRevealed, isTrue);
    // a later day draws a new card that has not been revealed yet
    c.night = 3;
    expect(c.eventRevealed, isFalse);
  });
}
