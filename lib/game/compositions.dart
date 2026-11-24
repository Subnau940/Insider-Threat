/// Recommended compositions (rulebook, section 3).
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

const _s3 = [
  RoleId.threatHunter,
  RoleId.incidentResponder,
  RoleId.deadMansSwitch,
];
const _s4 = [..._s3, RoleId.networkEngineer];
const _s5 = [..._s4, RoleId.socAnalyst];

/// Rows of the rulebook table, keyed by player count.
const Map<int, Composition> _table = {
  8: Composition(red: 2, purple: 0, special: _s3, defenders: 3),
  9: Composition(red: 2, purple: 0, special: _s4, defenders: 3),
  10: Composition(red: 2, purple: 0, special: _s5, defenders: 3),
  12: Composition(red: 3, purple: 0, special: _s5, defenders: 4),
  14: Composition(red: 3, purple: 1, special: _s5, defenders: 5),
  16: Composition(red: 3, purple: 1, special: _s5, defenders: 7),
  18: Composition(red: 4, purple: 1, special: _s5, defenders: 8),
};

const int minPlayers = 8;
const int maxPlayers = 18;

/// The rulebook gives 8, 9, 10, 12, 14, 16 and 18 players. For the counts in
/// between (11, 13, 15, 17) we take the row below and add one Defender.
Composition recommendedComposition(int players) {
  final n = players.clamp(minPlayers, maxPlayers);
  var base = minPlayers;
  for (final k in _table.keys) {
    if (k <= n) base = k;
  }
  final row = _table[base]!;
  return Composition(
    red: row.red,
    purple: row.purple,
    special: row.special,
    defenders: row.defenders + (n - base),
  );
}
