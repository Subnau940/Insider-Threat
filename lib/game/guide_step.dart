/// What the UI shows for one step of the narration. The game controller builds
/// these from its state; widgets only render them.
library;

import 'events.dart';
import 'models.dart';

enum StepKind {
  // night
  nightfall,
  engineer,
  linked,
  hunter,
  phishing,
  red,
  redSolo,
  purple,
  responder,
  dawn,
  // day
  morning,
  election,
  event,
  debate,
  vote,
  verdict,
  // chain reactions
  dms,
  succession,
}

enum PickStyle { blue, red, violet }

enum PrimaryStyle { primary, red }

class TileSpec {
  const TileSpec({
    required this.id,
    required this.name,
    required this.team,
    required this.selected,
    required this.locked,
    required this.dead,
  });

  final int id;
  final String name;
  final Team team;
  final bool selected;
  final bool locked;
  final bool dead;
}

class PickerSpec {
  const PickerSpec({
    required this.label,
    required this.tiles,
    required this.style,
    this.max = 1,
    this.noneLabel,
    this.noneSelected = false,
  });

  final String label;
  final List<TileSpec> tiles;
  final PickStyle style;
  final int max;

  /// When set, an extra "nobody" choice is shown after the tiles.
  final String? noneLabel;
  final bool noneSelected;
}

/// A player who went down, with the role revealed.
class DownEntry {
  const DownEntry({required this.name, required this.role, required this.team});

  final String name;
  final String role;
  final Team team;
}

class ResultLine {
  const ResultLine({required this.team, required this.text});

  final Team team;
  final String text;
}

class ToolsSpec {
  const ToolsSpec({
    required this.restoreOn,
    required this.killOn,
    required this.restoreEnabled,
    required this.killEnabled,
    required this.restoreSub,
    required this.killSub,
  });

  final bool restoreOn;
  final bool killOn;
  final bool restoreEnabled;
  final bool killEnabled;
  final String restoreSub;
  final String killSub;
}

class ClockSpec {
  const ClockSpec({
    required this.id,
    required this.seconds,
    this.controls = true,
    this.label = 'Time left',
  });

  /// Changes whenever the clock must restart from scratch.
  final String id;
  final int seconds;
  final bool controls;
  final String label;
}

class PhishRow {
  const PhishRow({required this.id, required this.name, required this.clicked});

  final int id;
  final String name;

  /// null = no answer yet, true = clicked, false = reported.
  final bool? clicked;
}

class DdosSpec {
  const DdosSpec({
    required this.current,
    required this.index,
    required this.total,
    required this.upcoming,
  });

  final String current;
  final int index;
  final int total;
  final List<String> upcoming;
}

class GuideStep {
  const GuideStep({
    required this.kind,
    required this.kicker,
    required this.title,
    required this.say,
    required this.todo,
    this.sub = '',
    this.team,
    this.tag,
    this.secret,
    this.banner,
    this.selKey,
    this.picker,
    this.results = const [],
    this.report,
    this.notice = const [],
    this.clock,
    this.tools,
    this.event,
    this.phish,
    this.ddos,
    this.canContinue = true,
    this.canBack = true,
    this.primaryLabel = 'Next',
    this.primaryStyle = PrimaryStyle.primary,
    this.sfxName = '',
    this.stepNo = 1,
    this.total = 1,
    this.progressLabel,
  });

  final StepKind kind;
  final String kicker;
  final String title;
  final String sub;
  final Team? team;
  final String? tag;
  final String say;
  final String todo;

  /// Narrator-only information that must not be read out loud.
  final String? secret;

  /// A heads-up shown under the title (for example "cannot vote today").
  final String? banner;

  /// Key of the selection edited by the picker.
  final String? selKey;
  final PickerSpec? picker;
  final List<ResultLine> results;

  /// null = no report block; empty list = "quiet night".
  final List<DownEntry>? report;

  /// Chain reaction results from the previous action.
  final List<DownEntry> notice;
  final ClockSpec? clock;
  final ToolsSpec? tools;
  final EventCard? event;
  final List<PhishRow>? phish;
  final DdosSpec? ddos;

  final bool canContinue;
  final bool canBack;
  final String primaryLabel;
  final PrimaryStyle primaryStyle;
  final String sfxName;

  final int stepNo;
  final int total;

  /// Replaces "Step n / m" in the top bar when set.
  final String? progressLabel;
}
