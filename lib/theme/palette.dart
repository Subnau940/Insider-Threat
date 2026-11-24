/// Raw colour ramps. Nothing in the UI should read these directly: go through
/// the semantic tokens in `AppColors` (app_theme.dart) so that re-skinning
/// stays a one-file job.
///
/// The -400 step is the primary of each ramp.
library;

import 'package:flutter/painting.dart';

/// Yellow. The brand primary; use it sparingly so it keeps its punch.
abstract final class Lime {
  static const c50 = Color(0xFFFBFFE7);
  static const c100 = Color(0xFFF3FFC4);
  static const c200 = Color(0xFFEAFF8F);
  static const c300 = Color(0xFFDFFF4E);
  static const c400 = Color(0xFFD4FA1B);
  static const c500 = Color(0xFFC1E505);
  static const c600 = Color(0xFFA7BF00);
  static const c700 = Color(0xFF879405);
  static const c800 = Color(0xFF71780B);
  static const c900 = Color(0xFF62660F);
  static const c950 = Color(0xFF383A04);
}

/// Pink.
abstract final class Blush {
  static const c50 = Color(0xFFFFF3FE);
  static const c100 = Color(0xFFFFE7FF);
  static const c200 = Color(0xFFFFCEFD);
  static const c300 = Color(0xFFFFA7F8);
  static const c400 = Color(0xFFFF6DF1);
  static const c500 = Color(0xFFF73EE5);
  static const c600 = Color(0xFFDB1EC5);
  static const c700 = Color(0xFFB6159F);
  static const c800 = Color(0xFF951381);
  static const c900 = Color(0xFF791668);
  static const c950 = Color(0xFF510143);
}

/// Blue.
abstract final class Picton {
  static const c50 = Color(0xFFF0F9FF);
  static const c100 = Color(0xFFE0F3FE);
  static const c200 = Color(0xFFBBE8FC);
  static const c300 = Color(0xFF7ED6FB);
  static const c400 = Color(0xFF38C1F6);
  static const c500 = Color(0xFF10AAE7);
  static const c600 = Color(0xFF0489C5);
  static const c700 = Color(0xFF056D9F);
  static const c800 = Color(0xFF085C84);
  static const c900 = Color(0xFF0D4C6D);
  static const c950 = Color(0xFF093148);
}

/// Neutral grey, very slightly warm.
abstract final class Cod {
  static const c50 = Color(0xFFF9FAF9);
  static const c100 = Color(0xFFF4F5F4);
  static const c200 = Color(0xFFE6E6E5);
  static const c300 = Color(0xFFD4D4D3);
  static const c400 = Color(0xFFA5A5A1);
  static const c500 = Color(0xFF747470);
  static const c600 = Color(0xFF535451);
  static const c700 = Color(0xFF41413F);
  static const c800 = Color(0xFF272726);
  static const c900 = Color(0xFF1A1A19);
  static const c950 = Color(0xFF0B0B0A);
}

/// Red. Not part of the chosen ramps: only the steps the app needs, kept
/// from the previous palette so the Red Team and danger read as red.
abstract final class Signal {
  static const c200 = Color(0xFFFF9DAE);
  static const c400 = Color(0xFFFF4D6A);
  static const c500 = Color(0xFFE63956);
}
