/// Recommended compositions (rules, section 5).
library;

import 'models.dart';

class Composition {
  const Composition({
    required this.red,
    required this.purple,
    required this.special,
    required this.defenders,
  });

  final int red;
  final int purple;
  final List<RoleId> special;
  final int defenders;

  int get total => red + purple + special.length + defenders;

  /// Every role card of the composition, one entry per card.
  List<RoleId> get pool => [
        ...List.filled(red, RoleId.red),
        ...List.filled(purple, RoleId.purple),
        ...special,
        ...List.filled(defenders, RoleId.defender),
      ];

  Map<RoleId, int> get counts {
    final out = <RoleId, int>{};
    for (final r in pool) {
      out[r] = (out[r] ?? 0) + 1;
    }
    return out;
  }
}

const _s2 = [RoleId.threatHunter, RoleId.incidentResponder];
const _s3 = [..._s2, RoleId.deadMansSwitch];
const _s4 = [..._s3, RoleId.networkEngineer];
const _s5 = [..._s4, RoleId.socAnalyst];

/// The rulebook table (section 5), one row per player count.
const Map<int, Composition> _table = {
  5: Composition(red: 1, purple: 0, special: _s2, defenders: 2),
  6: Composition(red: 1, purple: 0, special: _s3, defenders: 2),
  7: Composition(red: 2, purple: 0, special: _s3, defenders: 2),
  8: Composition(red: 2, purple: 0, special: _s3, defenders: 3),
  9: Composition(red: 2, purple: 0, special: _s4, defenders: 3),
  10: Composition(red: 2, purple: 0, special: _s5, defenders: 3),
  11: Composition(red: 3, purple: 0, special: _s5, defenders: 3),
  12: Composition(red: 3, purple: 0, special: _s5, defenders: 4),
  13: Composition(red: 3, purple: 0, special: _s5, defenders: 5),
  14: Composition(red: 3, purple: 1, special: _s5, defenders: 5),
};

const int minPlayers = 5;
const int maxPlayers = 14;

/// The Purple Team card is only dealt from this many players.
const int purpleMinPlayers = 14;

Composition recommendedComposition(int players) =>
    _table[players.clamp(minPlayers, maxPlayers)]!;
