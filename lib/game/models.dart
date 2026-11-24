/// Core domain types: teams, roles, players, outcomes.
library;

enum Team { red, blue, purple }

extension TeamX on Team {
  String get label => switch (this) {
        Team.red => 'Red Team',
        Team.blue => 'Blue Team',
        Team.purple => 'Purple Team',
      };
}

enum RoleId {
  red,
  defender,
  threatHunter,
  socAnalyst,
  incidentResponder,
  deadMansSwitch,
  networkEngineer,
  purple,
}

class RoleInfo {
  const RoleInfo({
    required this.id,
    required this.name,
    required this.team,
    required this.character,
    required this.tagline,
    required this.wakes,
    required this.power,
    this.unique = true,
  });

  final RoleId id;
  final String name;
  final Team team;

  /// Character name printed on the physical card.
  final String character;
  final String tagline;
  final String wakes;
  final String power;

  /// Only one card of this role exists in a game.
  final bool unique;
}

const Map<RoleId, RoleInfo> roleInfos = {
  RoleId.red: RoleInfo(
    id: RoleId.red,
    name: 'Red Team',
    team: Team.red,
    character: 'GHOSTLOAD',
    tagline: 'The hooded infiltrator with a rogue USB key.',
    wakes: 'Every night, together.',
    power:
        'Know each other. Each night they silently agree on one machine to compromise. They cannot target a fellow Red Team member.',
    unique: false,
  ),
  RoleId.defender: RoleInfo(
    id: RoleId.defender,
    name: 'Defender',
    team: Team.blue,
    character: 'BULWARK',
    tagline: 'The frontline guard, shield up.',
    wakes: 'Never.',
    power: 'No special power. Wins through logic, observation and the vote.',
    unique: false,
  ),
  RoleId.threatHunter: RoleInfo(
    id: RoleId.threatHunter,
    name: 'Threat Hunter',
    team: Team.blue,
    character: 'TRACER',
    tagline: 'The seeker, radar always on.',
    wakes: 'Every night.',
    power:
        'Points at one machine. The Narrator silently shows them that player\'s role card.',
  ),
  RoleId.socAnalyst: RoleInfo(
    id: RoleId.socAnalyst,
    name: 'SOC Analyst',
    team: Team.blue,
    character: 'NIGHTWATCH',
    tagline: 'The 24/7 monitoring operator.',
    wakes: 'Never called, may peek.',
    power:
        'May slightly open their eyes during the Red Team\'s turn. If caught, the Red Team may target them.',
  ),
  RoleId.incidentResponder: RoleInfo(
    id: RoleId.incidentResponder,
    name: 'Incident Responder',
    team: Team.blue,
    character: 'RESPAWN',
    tagline: 'Backup case in one hand, kill switch in the other.',
    wakes: 'Every night, after the Red Team.',
    power:
        'Sees tonight\'s victim. Two single-use tools: Backup Restore (save the victim) and Kill Process (eliminate any machine).',
  ),
  RoleId.deadMansSwitch: RoleInfo(
    id: RoleId.deadMansSwitch,
    name: 'Dead Man\'s Switch',
    team: Team.blue,
    character: 'FAILSAFE',
    tagline: 'Armed, timer at 00:00.',
    wakes: 'Only when eliminated.',
    power:
        'When it goes down, it immediately takes one machine of its choice down with it.',
  ),
  RoleId.networkEngineer: RoleInfo(
    id: RoleId.networkEngineer,
    name: 'Network Engineer',
    team: Team.blue,
    character: 'LINKSMITH',
    tagline: 'Cable on the shoulder, RJ45 in hand.',
    wakes: 'First night only.',
    power:
        'Links two machines with a VPN Tunnel. If one goes down, the other goes down too. Linked players never vote against each other.',
  ),
  RoleId.purple: RoleInfo(
    id: RoleId.purple,
    name: 'Purple Team',
    team: Team.purple,
    character: 'DUALBOOT',
    tagline: 'Half red, half blue, loyal to no one.',
    wakes: 'Every night with the Red Team + alone every second night.',
    power:
        'Seen by the Red Team as one of their own. Every second night it may eliminate one Red Team member. Wins by being the last machine standing.',
  ),
};

extension RoleIdX on RoleId {
  RoleInfo get info => roleInfos[this]!;
}

/// Order used when listing roles in pickers and the rules screen.
const List<RoleId> roleDisplayOrder = [
  RoleId.red,
  RoleId.threatHunter,
  RoleId.incidentResponder,
  RoleId.networkEngineer,
  RoleId.deadMansSwitch,
  RoleId.socAnalyst,
  RoleId.defender,
  RoleId.purple,
];

class Player {
  Player({required this.id, required this.name, required this.role});

  final int id;
  String name;
  RoleId role;
  bool alive = true;

  Team get team => role.info.team;
}

enum Winner { blue, red, purple, vpn, outage }
