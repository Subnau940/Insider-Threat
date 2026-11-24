import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insider_threat/game/events.dart';
import 'package:insider_threat/game/models.dart';
import 'package:insider_threat/main.dart';
import 'package:insider_threat/theme/app_theme.dart';
import 'package:insider_threat/ui/event_draw/sfx.dart';
import 'package:insider_threat/ui/rules_screen.dart';

void main() {
  setUp(() {
    AppText.useGoogleFonts = false;
    Sfx.enabled = false;
  });

  Future<void> sized(WidgetTester t, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  testWidgets('Rules button opens the rules, the select switches to roles', (t) async {
    await sized(t, const Size(390, 844));
    await t.pumpWidget(const InsiderThreatApp());

    await t.tap(find.text('RULES'));
    await t.pumpAndSettle();
    expect(find.byType(RulesScreen), findsOneWidget);
    expect(find.text('The goal'), findsOneWidget);
    expect(find.text('GAME RULES'), findsOneWidget);

    await t.tap(find.text('ROLES'));
    await t.pumpAndSettle();
    expect(find.text('GHOSTLOAD'), findsOneWidget);
    expect(find.text('The goal'), findsNothing);

    await t.tap(find.text('GAME RULES'));
    await t.pumpAndSettle();
    expect(find.text('The goal'), findsOneWidget);

    await t.tap(find.byTooltip('Back'));
    await t.pumpAndSettle();
    expect(find.byType(RulesScreen), findsNothing);
    expect(t.takeException(), isNull);
  });

  for (final size in [const Size(390, 844), const Size(320, 568)]) {
    testWidgets('every event and every role renders, ${size.width.toInt()}px', (t) async {
      await sized(t, size);

      await t.pumpWidget(const MaterialApp(home: RulesScreen()));
      final list = find.byType(Scrollable).last;
      for (final card in EventCard.values) {
        await t.scrollUntilVisible(find.text(card.info.title), 300, scrollable: list);
      }
      expect(t.takeException(), isNull);

      await t.pumpWidget(const MaterialApp(
          home: RulesScreen(key: ValueKey('roles'), initialTab: RulesTab.roles)));
      final roles = find.byType(Scrollable).last;
      for (final id in roleDisplayOrder) {
        await t.scrollUntilVisible(find.text(id.info.character), 300, scrollable: roles);
        expect(find.text(id.info.werewolf), findsWidgets);
      }
      await t.scrollUntilVisible(find.text('CISO'), 300, scrollable: roles);
      expect(t.takeException(), isNull);
    });
  }
}
