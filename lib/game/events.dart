/// Expert mode Event cards (Insider-Threat-Evenement.pdf, 10 events).
library;

enum EventCard {
  securityAudit,
  c2ServerDown,
  honeypot,
  powerOutage,
  zeroDay,
  maintenanceWindow,
  remoteWorkDay,
  phishing,
  blackFridayRush,
  ddos,
}

enum EventSide { blue, red, chaos }

extension EventSideX on EventSide {
  String get label => switch (this) {
        EventSide.blue => 'Helps Blue Team',
        EventSide.red => 'Helps Red Team',
        EventSide.chaos => 'Chaos',
      };
}

class EventInfo {
  const EventInfo({
    required this.number,
    required this.title,
    required this.side,
    required this.when,
    required this.description,
    required this.howTo,
  });

  final int number;
  final String title;
  final EventSide side;
  final String when;
  final String description;
  final String howTo;
}

const Map<EventCard, EventInfo> eventInfos = {
  EventCard.securityAudit: EventInfo(
    number: 1,
    title: 'Security Audit',
    side: EventSide.blue,
    when: 'Tonight',
    description:
        'An external security audit gives the Blue Team more resources to investigate.',
    howTo:
        'Tonight the Threat Hunter may inspect two machines. The app adapts the script: show both role cards, one after the other.',
  ),
  EventCard.c2ServerDown: EventInfo(
    number: 2,
    title: 'C2 Server Down',
    side: EventSide.blue,
    when: 'Tonight',
    description:
        'The attackers\' Command & Control server is down. They can no longer coordinate and must act alone.',
    howTo:
        'Tonight the Red Team (Purple included) is called one attacker at a time. If they all point at the same machine it is compromised, otherwise the attack fails.',
  ),
  EventCard.honeypot: EventInfo(
    number: 3,
    title: 'Honeypot',
    side: EventSide.blue,
    when: 'Tonight',
    description:
        'The Blue Team has set up a decoy on the network: a machine that looks vulnerable but is a trap.',
    howTo:
        'At nightfall the app secretly picks one online machine outside the Red Team. If the Red Team targets it, the attack fails. Tell nobody who the decoy is.',
  ),
  EventCard.powerOutage: EventInfo(
    number: 4,
    title: 'Power Outage',
    side: EventSide.red,
    when: 'Tonight',
    description: 'A power cut takes every defence tool offline.',
    howTo:
        'Tonight only the Red Team is called. No Threat Hunter, no Incident Responder, no Purple solo action, and the SOC Analyst cannot peek.',
  ),
  EventCard.zeroDay: EventInfo(
    number: 5,
    title: 'Zero-Day',
    side: EventSide.red,
    when: 'Tonight',
    description:
        'The Red Team exploits an unknown flaw that is also present in the backups: restoring the machine is useless.',
    howTo:
        'Tonight Backup Restore is unavailable. It is not used up: the Incident Responder keeps it for later. Kill Process still works.',
  ),
  EventCard.maintenanceWindow: EventInfo(
    number: 6,
    title: 'Maintenance Window',
    side: EventSide.red,
    when: 'Today',
    description:
        'A planned maintenance window freezes every change on the network today.',
    howTo:
        'The debate happens as usual. At the end, announce that no quarantine happens today. There is no vote.',
  ),
  EventCard.remoteWorkDay: EventInfo(
    number: 7,
    title: 'Remote Work Day',
    side: EventSide.red,
    when: 'Today',
    description:
        'Everyone works from home. Nobody meets at the coffee machine, so there is no discussion.',
    howTo:
        'No debate. Start the countdown right away: everyone points at a player in silence. Usual voting rules apply.',
  ),
  EventCard.phishing: EventInfo(
    number: 8,
    title: 'Phishing Campaign',
    side: EventSide.chaos,
    when: 'Tonight + next morning',
    description:
        'A malicious email is spreading through the company. Recipients cannot tell whether it is legitimate.',
    howTo:
        'Tonight, before the Red Team, the app flips a secret coin and picks 3 online players. They answer with their eyes closed: thumb up to click, thumb down to report. Announce the result in the morning.',
  ),
  EventCard.blackFridayRush: EventInfo(
    number: 9,
    title: 'Black Friday Rush',
    side: EventSide.chaos,
    when: 'Today',
    description: 'It\'s Black Friday: everyone is swamped and nobody has time to talk.',
    howTo: 'The debate lasts only 1 minute. Then the vote happens as usual.',
  ),
  EventCard.ddos: EventInfo(
    number: 10,
    title: 'DDoS',
    side: EventSide.chaos,
    when: 'Today',
    description:
        'The network is flooded by a denial-of-service attack: only one message gets through at a time.',
    howTo:
        'No free debate. One round, one player at a time, 20 seconds each, starting with the player to the left of the CISO. Nobody can interrupt.',
  ),
};

extension EventCardX on EventCard {
  EventInfo get info => eventInfos[this]!;
}

/// Text printed on the physical Event card (from the card design).
/// Words wrapped in `**double stars**` are highlighted.
class EventCardFace {
  const EventCardFace({required this.flavor, required this.effect, required this.when});

  final String flavor;
  final String effect;

  /// Short timing label printed on the card: TONIGHT or TODAY.
  final String when;
}

const Map<EventCard, EventCardFace> eventCardFaces = {
  EventCard.securityAudit: EventCardFace(
    when: 'TONIGHT',
    flavor: 'An external audit boosts the investigation.',
    effect: 'The Threat Hunter inspects **2 machines** instead of 1.',
  ),
  EventCard.c2ServerDown: EventCardFace(
    when: 'TONIGHT',
    flavor: "The attackers' Command & Control server is down.",
    effect:
        'Attackers are woken **one at a time** and point alone. The target goes down only if they **all** chose the same machine.',
  ),
  EventCard.honeypot: EventCardFace(
    when: 'TONIGHT',
    flavor: 'A decoy machine waits on the network.',
    effect:
        'The Narrator secretly picks a decoy (not Red Team). If the Red Team targets it, the attack **fails**: "Honeypot triggered."',
  ),
  EventCard.powerOutage: EventCardFace(
    when: 'TONIGHT',
    flavor: 'A power cut takes every defence tool offline.',
    effect:
        'Only the Red Team acts. **All special powers are offline**, and the SOC Analyst cannot peek.',
  ),
  EventCard.zeroDay: EventCardFace(
    when: 'TONIGHT',
    flavor: 'An unknown flaw, even in the backups.',
    effect: '**Backup Restore cannot be used** (it is not used up). Kill Process still works.',
  ),
  EventCard.maintenanceWindow: EventCardFace(
    when: 'TODAY',
    flavor: 'Planned maintenance freezes the network.',
    effect: 'Debate as usual, then **no vote and no quarantine** today.',
  ),
  EventCard.remoteWorkDay: EventCardFace(
    when: 'TODAY',
    flavor: 'No coffee machine, no discussion.',
    effect: '**No debate.** Everyone votes immediately, in silence.',
  ),
  EventCard.phishing: EventCardFace(
    when: 'TONIGHT',
    flavor: 'Click or report?',
    effect:
        '3 random players get an email. **Real phishing**: clickers go down, unless someone reported. **Legit email**: reporters cannot vote today.',
  ),
  EventCard.blackFridayRush: EventCardFace(
    when: 'TODAY',
    flavor: 'Everyone is swamped.',
    effect: 'The debate lasts only **1 minute**.',
  ),
  EventCard.ddos: EventCardFace(
    when: 'TODAY',
    flavor: 'One message at a time.',
    effect: 'No free debate. Each player speaks **once, in turn**, 20 seconds max.',
  ),
};

extension EventCardFaceX on EventCard {
  EventCardFace get face => eventCardFaces[this]!;
}
