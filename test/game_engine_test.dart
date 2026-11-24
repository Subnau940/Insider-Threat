import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:insider_threat/game/compositions.dart';
import 'package:insider_threat/game/events.dart';
import 'package:insider_threat/game/game_controller.dart';
import 'package:insider_threat/game/guide_step.dart';
import 'package:insider_threat/game/models.dart';

/// Eight players: 0-1 Red, 2 Threat Hunter, 3 Incident Responder,
/// 4 Dead Man's Switch, 5-7 Defenders.
const _eight = [
  RoleId.red,
  RoleId.red,
  RoleId.threatHunter,
  RoleId.incidentResponder,
  RoleId.deadMansSwitch,
  RoleId.defender,
  RoleId.defender,
  RoleId.defender,
];

GameController make(List<RoleId> roles, {bool expert = false, int seed = 1}) {
  final players = [
    for (var i = 0; i < roles.length; i++)
      Player(id: i, name: 'P$i', role: roles[i]),
  ];
  return GameController(players: players, expert: expert, random: Random(seed));
}

int _firstFree(GuideStep s) => s.picker!.tiles.firstWhere((t) => !t.locked).id;

/// Plays the whole night with the given choices.
void playNight(
  GameController c, {
  int? victim,
  int? hunter,
  List<int> link = const [],
  bool restore = false,
  int? kill,
  int? purple,
}) {
  var guard = 0;
  while (c.phase == GamePhase.night && guard++ < 40) {
    final s = c.currentStep;
    switch (s.kind) {
      case StepKind.engineer:
        if (s.picker != null) link.forEach(c.pick);
      case StepKind.hunter:
        if (s.picker != null) {
          final need = s.picker!.max;
          c.pick(hunter ?? _firstFree(s));
          if (need == 2) {
            c.pick(s.picker!.tiles.firstWhere((t) => !t.locked && !t.selected && t.id != (hunter ?? -1)).id);
          }
        }
      case StepKind.red:
        c.pick(victim!);
      case StepKind.purple:
        if (s.picker != null) {
          if (purple != null) {
            c.pick(purple);
          } else {
            c.pickNone();
          }
        }
      case StepKind.responder:
        if (s.tools != null) {
          if (restore) c.toggleRestore();
          if (kill != null) {
            c.toggleKill();
            c.pick(kill);
          }
        }
      default:
        break;
    }
    c.primary();
  }
  expect(guard, lessThan(40), reason: 'night did not finish');
}

/// Moves through the day up to the vote, electing [ciso] if needed.
void toVote(GameController c, {int? ciso}) {
  var guard = 0;
  while (c.phase == GamePhase.day &&
      !(c.dayStage == DayStage.vote && !c.inChain) &&
      guard++ < 20) {
    final s = c.currentStep;
    if (s.kind == StepKind.election) {
      c.pick(ciso ?? c.alivePlayers.first.id);
    } else if (s.kind == StepKind.quizAnswer) {
      c.setQuizCorrect(0);
    } else if (s.kind == StepKind.dms || s.kind == StepKind.succession) {
      break;
    }
    c.primary();
  }
}

/// Quarantines [id] and goes through the verdict.
void quarantine(GameController c, int id) {
  c.pick(id);
  c.primary(); // vote -> verdict
  expect(c.dayStage, DayStage.verdict);
  c.primary(); // verdict -> chain / night
}

/// Night 1 + Day 1 with no major effect: a defender (7) is compromised and a
/// defender (6) is quarantined. Leaves the game at the start of night 2.
void reachNight2(GameController c, {EventCard? event}) {
  playNight(c, victim: 7);
  toVote(c, ciso: 5);
  if (event != null) c.debugSetTodayEvent(event);
  quarantine(c, 6);
  expect(c.phase, GamePhase.night);
  expect(c.night, 2);
}

void main() {
  group('compositions', () {
    test('every count from 8 to 18 adds up', () {
      for (var n = minPlayers; n <= maxPlayers; n++) {
        final comp = recommendedComposition(n);
        expect(comp.total, n, reason: '$n players');
        expect(comp.pool.length, n);
      }
    });

    test('matches the rulebook table', () {
      final c8 = recommendedComposition(8);
      expect((c8.red, c8.purple, c8.defenders), (2, 0, 3));
      final c14 = recommendedComposition(14);
      expect((c14.red, c14.purple, c14.defenders), (3, 1, 5));
      final c18 = recommendedComposition(18);
      expect((c18.red, c18.purple, c18.defenders), (4, 1, 8));
      // in-between counts add Defenders to the row below
      expect(recommendedComposition(11).defenders, 4);
    });
  });

  group('win conditions', () {
    GameController wc(List<RoleId> roles) => make(roles);

    test('blue wins when every red and purple machine is out', () {
      final c = wc(_eight);
      c.players[0].alive = false;
      c.players[1].alive = false;
      expect(c.checkWinner(), Winner.blue);
    });

    test('red wins only when nobody else is left', () {
      final c = wc(_eight);
      for (final p in c.players.skip(2)) {
        p.alive = false;
      }
      expect(c.checkWinner(), Winner.red);
    });

    test('red does not win just by outnumbering blue', () {
      final c = wc(_eight);
      for (final i in [2, 3, 4, 5, 6]) {
        c.players[i].alive = false;
      }
      // 2 red vs 1 defender: the game goes on
      expect(c.checkWinner(), isNull);
    });

    test('purple wins alone, and the game goes on with red + purple', () {
      final c = wc([...List.of(_eight)..[7] = RoleId.purple]);
      for (final i in [2, 3, 4, 5, 6]) {
        c.players[i].alive = false;
      }
      expect(c.checkWinner(), isNull); // red 0,1 + purple 7
      c.players[0].alive = false;
      c.players[1].alive = false;
      expect(c.checkWinner(), Winner.purple);
    });

    test('VPN of two teams wins when they are the last two', () {
      final c = wc(_eight);
      c.link = [0, 5];
      for (final i in [1, 2, 3, 4, 6, 7]) {
        c.players[i].alive = false;
      }
      expect(c.checkWinner(), Winner.vpn);
    });

    test('VPN of the same team does not trigger the special win', () {
      final c = wc(_eight);
      c.link = [5, 6];
      for (final i in [0, 1, 2, 3, 4, 7]) {
        c.players[i].alive = false;
      }
      expect(c.checkWinner(), Winner.blue);
    });

    test('total outage when nobody is left', () {
      final c = wc(_eight);
      for (final p in c.players) {
        p.alive = false;
      }
      expect(c.checkWinner(), Winner.outage);
    });
  });

  group('night', () {
    test('night 1 order without Network Engineer', () {
      final c = make(_eight);
      final kinds = <StepKind>[];
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        kinds.add(s.kind);
        if (s.kind == StepKind.red) c.pick(7);
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      expect(kinds, [
        StepKind.nightfall,
        StepKind.hunter,
        StepKind.red,
        StepKind.responder,
        StepKind.dawn,
      ]);
    });

    test('Network Engineer links two machines on night 1 only', () {
      final roles = [..._eight, RoleId.networkEngineer];
      final c = make(roles);
      final first = <StepKind>[];
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        first.add(s.kind);
        if (s.kind == StepKind.engineer) {
          expect(s.canContinue, isFalse);
          c.pick(5);
          c.pick(8);
        }
        if (s.kind == StepKind.red) c.pick(6);
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      expect(first, contains(StepKind.engineer));
      expect(first, contains(StepKind.linked));
      expect(c.link, [5, 8]);
    });

    test('victim is compromised and the VPN partner goes down too', () {
      final roles = [..._eight, RoleId.networkEngineer];
      final c = make(roles);
      playNight(c, victim: 5, link: [5, 6]);
      expect(c.phase, GamePhase.day);
      expect(c.players[5].alive, isFalse);
      expect(c.players[6].alive, isFalse);
      expect(c.morningIds, [5, 6]);
    });

    test('Backup Restore saves the victim and is used up', () {
      final c = make(_eight);
      playNight(c, victim: 7, restore: true);
      expect(c.players[7].alive, isTrue);
      expect(c.restoreUsed, isTrue);
      expect(c.morningIds, isEmpty);
      expect(c.currentStep.say, contains('Quiet night'));
    });

    test('Kill Process takes another machine down', () {
      final c = make(_eight);
      playNight(c, victim: 7, kill: 1); // kills a Red Team member
      expect(c.players[7].alive, isFalse);
      expect(c.players[1].alive, isFalse);
      expect(c.killUsed, isTrue);
    });

    test('Red Team cannot target its own, nor a dead machine', () {
      final c = make(_eight);
      var guard = 0;
      while (c.currentStep.kind != StepKind.red && guard++ < 10) {
        final s = c.currentStep;
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      final tiles = c.currentStep.picker!.tiles;
      expect(tiles[0].locked, isTrue);
      expect(tiles[1].locked, isTrue);
      expect(tiles[5].locked, isFalse);
    });

    test('a role whose holder is out is still called', () {
      final c = make(_eight);
      reachNight2(c);
      c.players[2].alive = false; // Threat Hunter out
      final hunter = _stepOf(c, StepKind.hunter);
      expect(hunter.tag, 'Eliminated');
      expect(hunter.picker, isNull);
      expect(hunter.canContinue, isTrue);
    });

    test('Purple acts on even nights only', () {
      final roles = [..._eight, RoleId.purple];
      final c = make(roles);
      // night 1: no Purple step
      var kinds = <StepKind>[];
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        kinds.add(s.kind);
        if (s.kind == StepKind.red) c.pick(5);
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      expect(kinds, isNot(contains(StepKind.purple)));

      toVote(c, ciso: 6);
      quarantine(c, 7);
      expect(c.night, 2);
      playNight(c, victim: 6, purple: 1);
      expect(c.players[1].alive, isFalse, reason: 'Purple eliminated a Red');
    });

    test('Incident Responder tools stay used across nights', () {
      final c = make(_eight);
      playNight(c, victim: 7, restore: true);
      toVote(c, ciso: 5);
      quarantine(c, 6);
      final s = _stepOf(c, StepKind.responder, victim: 5);
      expect(s.tools!.restoreEnabled, isFalse);
      expect(s.tools!.restoreSub, 'Already used');
      expect(s.tools!.killEnabled, isTrue);
    });
  });

  group('day', () {
    test('Day 1 elects the CISO before the debate', () {
      final c = make(_eight);
      playNight(c, victim: 7);
      expect(c.currentStep.kind, StepKind.morning);
      c.primary();
      expect(c.currentStep.kind, StepKind.election);
      expect(c.currentStep.canContinue, isFalse);
      c.pick(5);
      expect(c.ciso, 5);
      c.primary();
      expect(c.currentStep.kind, StepKind.debate);
      c.primary();
      expect(c.currentStep.kind, StepKind.vote);
    });

    test('quarantine reveals the role and leads to the next night', () {
      final c = make(_eight);
      playNight(c, victim: 7);
      toVote(c, ciso: 5);
      c.pick(6);
      expect(c.currentStep.primaryLabel, 'Quarantine P6');
      c.primary();
      expect(c.currentStep.kind, StepKind.verdict);
      expect(c.currentStep.report!.single.role, 'Defender');
      c.primary();
      expect(c.phase, GamePhase.night);
      expect(c.night, 2);
    });

    test('quarantining the last Red Team machine ends the game', () {
      final c = make(_eight);
      c.players[1].alive = false;
      playNight(c, victim: 7);
      toVote(c, ciso: 5);
      quarantine(c, 0);
      expect(c.phase, GamePhase.end);
      expect(c.winner, Winner.blue);
    });

    test('Dead Man\'s Switch takes a machine down with it', () {
      final c = make(_eight);
      playNight(c, victim: 7);
      toVote(c, ciso: 5);
      c.pick(4);
      c.primary(); // -> verdict
      c.primary(); // -> chain
      expect(c.inChain, isTrue);
      expect(c.currentStep.kind, StepKind.dms);
      expect(c.currentStep.canContinue, isFalse);
      c.pick(0); // takes a Red down
      expect(c.currentStep.primaryLabel, 'Take down P0');
      c.primary();
      expect(c.players[0].alive, isFalse);
      expect(c.phase, GamePhase.night);
    });

    test('Dead Man\'s Switch can fire on a night victim', () {
      final c = make(_eight);
      playNight(c, victim: 4);
      expect(c.currentStep.kind, StepKind.morning);
      c.primary();
      expect(c.currentStep.kind, StepKind.dms);
      c.pickNone();
      c.primary();
      expect(c.currentStep.kind, StepKind.election);
    });

    test('a CISO who goes down names a successor', () {
      final c = make(_eight);
      playNight(c, victim: 7);
      toVote(c, ciso: 5);
      quarantine(c, 5);
      expect(c.inChain, isTrue);
      expect(c.currentStep.kind, StepKind.succession);
      c.pick(6);
      c.primary();
      expect(c.ciso, 6);
      expect(c.phase, GamePhase.night);
    });

    test('a tie with no CISO allows nobody to be quarantined', () {
      final c = make(_eight);
      playNight(c, victim: 7);
      toVote(c, ciso: 5);
      expect(c.currentStep.picker!.noneLabel, isNull); // there is a CISO
      c.ciso = null;
      expect(c.currentStep.picker!.noneLabel, isNotNull);
      c.pickNone();
      c.primary();
      expect(c.currentStep.report, isEmpty);
    });
  });

  group('expert events', () {
    test('Security Audit: two inspections', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.securityAudit);
      final s = _stepOf(c, StepKind.hunter);
      expect(s.picker!.max, 2);
      expect(s.say, contains('two machines'));
    });

    test('Power Outage: only the Red Team is called', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.powerOutage);
      final kinds = <StepKind>[];
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 10) {
        final s = c.currentStep;
        kinds.add(s.kind);
        if (s.kind == StepKind.red) c.pick(5);
        c.primary();
      }
      expect(kinds, [StepKind.nightfall, StepKind.red, StepKind.dawn]);
    });

    test('Zero-Day: Backup Restore is offline but not used up', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.zeroDay);
      final s = _stepOf(c, StepKind.responder, victim: 5);
      expect(s.tools!.restoreEnabled, isFalse);
      expect(s.tools!.restoreSub, 'Offline tonight');
      expect(s.say, contains('unavailable'));
      c.primary(); // responder
      c.primary(); // dawn
      expect(c.restoreUsed, isFalse);
      expect(c.players[5].alive, isFalse);
    });

    test('Honeypot: targeting the decoy blocks the attack', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.honeypot);
      final decoy = c.honeypotId!;
      expect(c.players[decoy].team, Team.blue);
      expect(c.currentStep.secret, contains(c.players[decoy].name));
      playNight(c, victim: decoy);
      expect(c.players[decoy].alive, isTrue);
      expect(c.currentStep.say, contains('Honeypot triggered'));
    });

    test('Honeypot: another target goes through, silently', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.honeypot);
      final decoy = c.honeypotId!;
      final other = [2, 3, 4, 5].firstWhere((i) => i != decoy);
      playNight(c, victim: other);
      expect(c.players[other].alive, isFalse);
      expect(c.currentStep.say, isNot(contains('Honeypot')));
    });

    test('C2 Server Down: attackers act one by one, unanimity needed', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.c2ServerDown);
      var guard = 0;
      var solos = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        if (s.kind == StepKind.redSolo) {
          solos++;
          c.pick(solos == 1 ? 5 : 3); // they disagree
        }
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      expect(solos, 2);
      expect(c.morningIds, isEmpty, reason: 'the attack fails');
      expect(c.players[5].alive, isTrue);
      expect(c.players[3].alive, isTrue);
    });

    test('C2 Server Down: a unanimous target is compromised', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.c2ServerDown);
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        if (s.kind == StepKind.redSolo) c.pick(5);
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      expect(c.players[5].alive, isFalse);
    });

    test('Phishing: a real campaign compromises everyone who clicked', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.phishing);
      c.phishReal = true;
      expect(c.phishTargets.length, 3);
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        if (s.kind == StepKind.phishing) {
          expect(s.canContinue, isFalse);
          for (final id in c.phishTargets) {
            c.answerPhish(id, clicked: true);
          }
        }
        if (s.kind == StepKind.red) {
          // aim at a machine that is not a phishing recipient if possible
          final free = s.picker!.tiles.firstWhere((t) => !t.locked);
          c.pick(free.id);
        }
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      for (final id in c.phishTargets) {
        expect(c.players[id].alive, isFalse);
      }
    });

    test('Phishing: one report blocks a real campaign', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.phishing);
      c.phishReal = true;
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        if (s.kind == StepKind.phishing) {
          for (final id in c.phishTargets) {
            c.answerPhish(id, clicked: id != c.phishTargets.first);
          }
        }
        if (s.kind == StepKind.red) c.pick(_firstFree(s));
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      // only the Red Team's victim (at most one) went down
      expect(c.morningIds.length, lessThanOrEqualTo(1));
      expect(c.currentStep.say, contains('Phishing reported and blocked'));
    });

    test('Phishing: reporting a legit email costs your vote', () {
      final c = make(_eight);
      reachNight2(c, event: EventCard.phishing);
      c.phishReal = false;
      var guard = 0;
      while (c.phase == GamePhase.night && guard++ < 20) {
        final s = c.currentStep;
        if (s.kind == StepKind.phishing) {
          for (final id in c.phishTargets) {
            c.answerPhish(id, clicked: false);
          }
        }
        if (s.kind == StepKind.red) c.pick(_firstFree(s));
        if (s.kind == StepKind.hunter) c.pick(_firstFree(s));
        c.primary();
      }
      expect(c.voteBanned, isNotEmpty);
      expect(c.currentStep.banner, startsWith('Cannot vote today'));
    });

    test('Maintenance Window: debate, then no vote', () {
      final c = make(_eight, expert: true);
      reachNight2(c);
      playNight(c, victim: 3);
      c.primary(); // morning -> (election) / event
      var guard = 0;
      while (c.currentStep.kind != StepKind.event && guard++ < 5) {
        final s = c.currentStep;
        if (s.kind == StepKind.election) c.pick(c.alivePlayers.first.id);
        c.primary();
      }
      c.debugSetTodayEvent(EventCard.maintenanceWindow);
      c.primary(); // event -> debate
      expect(c.currentStep.kind, StepKind.debate);
      c.primary(); // debate -> vote (cancelled)
      expect(c.currentStep.kind, StepKind.vote);
      expect(c.currentStep.picker, isNull);
      expect(c.currentStep.say, contains('no quarantine'));
      c.primary();
      expect(c.phase, GamePhase.night);
      expect(c.night, 3);
    });

    test('Remote Work Day: no debate', () {
      final c = make(_eight, expert: true);
      reachNight2(c);
      playNight(c, victim: 3);
      c.primary(); // morning
      for (var g = 0; g < 8 && c.currentStep.kind != StepKind.event; g++) {
        if (c.currentStep.kind == StepKind.election) c.pick(c.alivePlayers.first.id);
        c.primary();
      }
      c.debugSetTodayEvent(EventCard.remoteWorkDay);
      c.primary();
      expect(c.currentStep.kind, StepKind.vote);
      expect(c.currentStep.say, contains('in silence'));
    });

    test('Black Friday Rush: one minute of debate', () {
      final c = make(_eight, expert: true);
      reachNight2(c);
      playNight(c, victim: 3);
      c.primary();
      for (var g = 0; g < 8 && c.currentStep.kind != StepKind.event; g++) {
        if (c.currentStep.kind == StepKind.election) c.pick(c.alivePlayers.first.id);
        c.primary();
      }
      c.debugSetTodayEvent(EventCard.blackFridayRush);
      c.primary();
      expect(c.currentStep.kind, StepKind.debate);
      expect(c.currentStep.clock!.seconds, 60);
    });

    test('DDoS: everyone speaks once, starting left of the CISO', () {
      final c = make(_eight, expert: true);
      reachNight2(c);
      playNight(c, victim: 3);
      c.primary();
      for (var g = 0; g < 8 && c.currentStep.kind != StepKind.event; g++) {
        c.primary();
      }
      c.debugSetTodayEvent(EventCard.ddos);
      c.primary();
      final alive = c.alivePlayers.length;
      var s = c.currentStep;
      expect(s.kind, StepKind.debate);
      expect(s.ddos!.current, 'P0', reason: 'left of the CISO (P5)');
      expect(s.clock!.seconds, 20);
      var spoke = 1;
      for (var g = 0; g < 20 && c.currentStep.ddos != null; g++) {
        c.primary();
        s = c.currentStep;
        if (s.ddos != null) spoke++;
      }
      expect(spoke, alive);
      expect(c.currentStep.kind, StepKind.vote);
    });

    test('events are drawn without replacement, then reshuffled', () {
      final c = make(_eight, expert: true, seed: 3);
      c.ciso = 5;
      c.phase = GamePhase.day;
      c.night = 2;
      final seen = <EventCard>[];
      for (var i = 0; i < 10; i++) {
        c.todayEvent = null;
        c.skipDebate = false;
        c.skipVote = false;
        c.dayStage = DayStage.morning;
        c.primary(); // morning -> event (drawn on entry)
        expect(c.dayStage, DayStage.event);
        seen.add(c.todayEvent!);
      }
      expect(seen.toSet().length, 10);
      c.todayEvent = null;
      c.dayStage = DayStage.morning;
      c.primary();
      expect(c.todayEvent, isNotNull, reason: 'deck reshuffled');
    });
  });

  test('a whole game can be played to the end', () {
    final c = make(_eight, seed: 7);
    var guard = 0;
    while (c.phase != GamePhase.end && guard++ < 400) {
      final s = c.currentStep;
      switch (s.kind) {
        case StepKind.hunter:
          if (s.picker != null) c.pick(_firstFree(s));
        case StepKind.red:
          c.pick(s.picker!.tiles.firstWhere((t) => !t.locked).id);
        case StepKind.election:
        case StepKind.succession:
        case StepKind.dms:
          c.pick(s.picker!.tiles.firstWhere((t) => !t.locked).id);
        case StepKind.vote:
          // quarantine the first living Red Team machine
          final red = c.alivePlayers.firstWhere((p) => p.team == Team.red);
          c.pick(red.id);
        default:
          break;
      }
      c.primary();
    }
    expect(c.phase, GamePhase.end);
    expect(c.winner, isNotNull);
  });

  group('expert quiz', () {
    /// Day 2 of an expert game (5 players left), stopped on the Event step
    /// with [card] drawn.
    GameController atEvent(EventCard card) {
      final c = make(_eight, expert: true);
      reachNight2(c);
      playNight(c, victim: 3);
      c.primary(); // morning
      for (var g = 0; g < 8 && c.currentStep.kind != StepKind.event; g++) {
        if (c.currentStep.kind == StepKind.election) c.pick(c.alivePlayers.first.id);
        c.primary();
      }
      expect(c.currentStep.kind, StepKind.event);
      expect(c.alivePlayers.length, 5);
      c.debugDrawEvent(card);
      return c;
    }

    /// Goes through the quiz, entering [right] correct answers.
    void answer(GameController c, int right) {
      c.primary(); // event -> quiz
      final q = c.currentStep;
      expect(q.kind, StepKind.quiz);
      expect(q.quiz!.revealed, isFalse);
      expect(q.clock!.seconds, 10);
      c.primary(); // quiz -> answer
      expect(c.currentStep.kind, StepKind.quizAnswer);
      expect(c.currentStep.quiz!.revealed, isTrue);
      expect(c.currentStep.canContinue, isFalse, reason: 'count not entered yet');
      c.setQuizCorrect(right);
      expect(c.currentStep.canContinue, isTrue);
      c.primary(); // answer -> result
      expect(c.currentStep.kind, StepKind.eventResult);
    }

    test('answers are shuffled but the right one is kept', () {
      for (final card in EventCard.values) {
        final c = atEvent(card);
        c.primary();
        final q = c.currentStep.quiz!;
        expect(q.answers.toSet(), card.quiz.answers.toSet());
        expect(q.answers[q.correct], card.quiz.answers[card.quiz.correct]);
        expect(q.needed, 3, reason: 'more than half of 5');
      }
    });

    test('Blue Event happens with more than half right', () {
      final c = atEvent(EventCard.securityAudit);
      answer(c, 3);
      expect(c.eventOutcome, EventOutcome.happens);
      expect(c.activeEvent, EventCard.securityAudit);
      expect(c.currentStep.title, 'Security Audit happens');
    });

    test('Blue Event is blocked with half or less right, also at night', () {
      final c = atEvent(EventCard.securityAudit);
      answer(c, 2);
      expect(c.eventOutcome, EventOutcome.blocked);
      expect(c.activeEvent, isNull);
      toVote(c);
      quarantine(c, 0); // a Red Team member: no chain reaction
      expect(c.phase, GamePhase.night);
      expect(c.nightEvent, isNull);
      final s = _stepOf(c, StepKind.hunter);
      expect(s.picker!.max, 1, reason: 'no second inspection');
    });

    test('Red Event is blocked with more than half right', () {
      final c = atEvent(EventCard.remoteWorkDay);
      answer(c, 3);
      expect(c.eventOutcome, EventOutcome.blocked);
      expect(c.currentStep.say, contains('blocked'));
      c.primary(); // result -> debate, not skipped
      expect(c.currentStep.kind, StepKind.debate);
    });

    test('Red Event happens with half or less right', () {
      final c = atEvent(EventCard.remoteWorkDay);
      answer(c, 2);
      expect(c.eventOutcome, EventOutcome.happens);
      c.primary(); // result -> vote, no debate
      expect(c.currentStep.kind, StepKind.vote);
      expect(c.currentStep.say, contains('in silence'));
    });

    test('Chaos Event always happens', () {
      final c = atEvent(EventCard.blackFridayRush);
      answer(c, 5);
      expect(c.eventOutcome, EventOutcome.happens);
      c.primary();
      expect(c.currentStep.kind, StepKind.debate);
      expect(c.currentStep.clock!.seconds, 60);
    });

    test('going back and changing the count re-decides the Event', () {
      final c = atEvent(EventCard.maintenanceWindow);
      answer(c, 0); // Red Event, nobody right: it happens
      expect(c.skipVote, isTrue);
      c.back(); // result -> answer
      expect(c.currentStep.kind, StepKind.quizAnswer);
      c.setQuizCorrect(5);
      c.primary();
      expect(c.eventOutcome, EventOutcome.blocked);
      expect(c.skipVote, isFalse);
    });
  });
}

/// Moves a fresh night to [kind], answering the steps in between.
GuideStep _stepOf(GameController c, StepKind kind, {int victim = 5}) {
  var guard = 0;
  while (c.currentStep.kind != kind && guard++ < 20) {
    final s = c.currentStep;
    if (s.kind == StepKind.hunter && s.picker != null) {
      for (var n = 0; n < s.picker!.max; n++) {
        c.pick(s.picker!.tiles.firstWhere((t) => !t.locked && !t.selected).id);
      }
    }
    if (s.kind == StepKind.red) c.pick(victim);
    c.primary();
  }
  return c.currentStep;
}
