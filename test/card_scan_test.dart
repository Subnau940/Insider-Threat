import 'package:flutter_test/flutter_test.dart';
import 'package:insider_threat/game/card_code.dart';
import 'package:insider_threat/game/compositions.dart';
import 'package:insider_threat/game/models.dart';
import 'package:insider_threat/game/setup_controller.dart';

void main() {
  group('parseCardCode', () {
    test('reads every printed card', () {
      // Same deck as qr-codes/: the 18-player composition, numbered per role.
      final seen = <RoleId, int>{};
      for (final role in recommendedComposition(18).pool) {
        final n = seen[role] = (seen[role] ?? 0) + 1;
        final text = CardCode(role: role, number: n).text;
        final card = parseCardCode(text);
        expect(card, isNotNull, reason: text);
        expect(card!.role, role);
        expect(card.number, n);
      }
      expect(seen.values.fold(0, (a, b) => a + b), 18);
    });

    test('matches the generated QR payloads', () {
      expect(parseCardCode('INSIDERTHREAT:1:red:03')!.role, RoleId.red);
      expect(parseCardCode('INSIDERTHREAT:1:dead_mans_switch:01')!.role,
          RoleId.deadMansSwitch);
      expect(parseCardCode('INSIDERTHREAT:1:defender:07')!.id, 'defender:07');
      expect(parseCardCode('  INSIDERTHREAT:1:purple:01\n')!.role, RoleId.purple);
    });

    test('rejects anything else', () {
      for (final raw in [
        null,
        '',
        'https://example.com',
        'INSIDERTHREAT:2:red:01', // unknown version
        'INSIDERTHREAT:1:wizard:01', // unknown role
        'INSIDERTHREAT:1:red', // missing number
        'INSIDERTHREAT:1:red:00',
        'OTHERGAME:1:red:01',
      ]) {
        expect(parseCardCode(raw), isNull, reason: '$raw');
      }
    });
  });

  group('SetupController.assignCard', () {
    CardCode card(String raw) => parseCardCode(raw)!;

    test('gives the role and remembers the card', () {
      final s = SetupController();
      final r = s.assignCard(0, card('INSIDERTHREAT:1:threat_hunter:01'));
      expect(r.outcome, ScanOutcome.assigned);
      expect(s.roles[0], RoleId.threatHunter);
      expect(s.cards[0], 'threat_hunter:01');
      expect(s.nextUnassigned, 1);
    });

    test('the same card cannot go to two players', () {
      final s = SetupController();
      s.assignCard(0, card('INSIDERTHREAT:1:defender:02'));
      final again = s.assignCard(0, card('INSIDERTHREAT:1:defender:02'));
      expect(again.outcome, ScanOutcome.sameCard);
      final other = s.assignCard(3, card('INSIDERTHREAT:1:defender:02'));
      expect(other.outcome, ScanOutcome.cardUsed);
      expect(other.other, 0);
      expect(s.roles[3], isNull);
    });

    test('two different Defender cards are fine', () {
      final s = SetupController();
      s.assignCard(0, card('INSIDERTHREAT:1:defender:01'));
      final r = s.assignCard(1, card('INSIDERTHREAT:1:defender:02'));
      expect(r.outcome, ScanOutcome.assigned);
    });

    test('a unique role picked by hand blocks the scan', () {
      final s = SetupController();
      s.setRole(2, RoleId.incidentResponder);
      final r = s.assignCard(5, card('INSIDERTHREAT:1:incident_responder:01'));
      expect(r.outcome, ScanOutcome.roleTaken);
      expect(r.other, 2);
    });

    test('rescanning a player replaces their role', () {
      final s = SetupController();
      s.assignCard(0, card('INSIDERTHREAT:1:red:01'));
      s.assignCard(0, card('INSIDERTHREAT:1:defender:01'));
      expect(s.roles[0], RoleId.defender);
      expect(s.cards[0], 'defender:01');
      // the Red card is free again
      final r = s.assignCard(1, card('INSIDERTHREAT:1:red:01'));
      expect(r.outcome, ScanOutcome.assigned);
    });

    test('picking by hand forgets the scanned card', () {
      final s = SetupController();
      s.assignCard(0, card('INSIDERTHREAT:1:red:01'));
      s.setRole(0, RoleId.defender);
      expect(s.cards[0], isNull);
    });

    test('scanning every card fills the table and allows the start', () {
      final s = SetupController()..setCount(8);
      final seen = <RoleId, int>{};
      final pool = recommendedComposition(8).pool;
      for (var i = 0; i < pool.length; i++) {
        final n = seen[pool[i]] = (seen[pool[i]] ?? 0) + 1;
        expect(s.assignCard(i, CardCode(role: pool[i], number: n)).outcome,
            ScanOutcome.assigned);
      }
      expect(s.nextUnassigned, isNull);
      expect(s.canStart, isTrue);
    });
  });
}
