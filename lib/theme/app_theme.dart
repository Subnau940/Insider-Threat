/// Semantic design tokens, mapped onto the raw ramps in `palette.dart`
/// (lime / pink / blue / grey, primary = the -400 step). Re-skinning the app
/// starts here.
///
/// Roles: [primary] (lime) is the brand accent and the call to action, kept
/// for what is actionable or selected so it does not dominate. [blue] is
/// narration and the Defenders, [pink] is danger and the Red Team.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/models.dart';
import 'palette.dart';

abstract final class AppColors {
  // Neutrals: dark background, surfaces get lighter as they rise.
  static const bg = Cod.c950;
  static const surface = Cod.c900;
  static const surfaceHigh = Cod.c800;
  static const line = Cod.c800;
  static const text = Cod.c50;
  static const textSoft = Cod.c300;
  static const muted = Cod.c400;
  static const disabledBg = Cod.c900;
  static const disabledText = Cod.c600;

  // Brand / actionable / selected.
  static const primary = Lime.c400;
  static const primarySoft = Lime.c200;
  static const onAccent = Cod.c950;

  // Narration, info, Defenders.
  static const blue = Picton.c400;
  static const blueSoft = Picton.c300;

  // Danger, Red Team.
  static const pink = Blush.c400;
  static const pinkSoft = Blush.c200;

  /// Faint grid lines on the Event card.
  static const grid = Color(0x17A5A5A1);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Lime.c400, Lime.c500],
  );
  static const pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Blush.c400, Blush.c500],
  );
  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Picton.c300, Picton.c400],
  );

  /// Purple has no ramp of its own: the lone wildcard takes the brand lime.
  static Color team(Team t) => switch (t) {
        Team.red => pink,
        Team.blue => blue,
        Team.purple => primary,
      };
}

abstract final class AppText {
  /// Tests turn this off so that no font is fetched from the network.
  static bool useGoogleFonts = true;

  static TextStyle ui(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.text,
    double? height,
    double? spacing,
    TextDecoration? decoration,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
      decoration: decoration,
    );
    return useGoogleFonts ? GoogleFonts.chakraPetch(textStyle: base) : base;
  }

  /// Body copy: Satoshi, bundled (assets/fonts) so it works offline. Titles
  /// and buttons stay on [ui], labels on [mono].
  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.text,
    double? height,
    double? spacing,
    TextDecoration? decoration,
  }) =>
      TextStyle(
        fontFamily: 'Satoshi',
        fontSize: size,
        fontWeight: weight,
        // Satoshi is a variable font: drive its weight axis explicitly.
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
        color: color,
        height: height,
        letterSpacing: spacing,
        decoration: decoration,
      );

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.muted,
    double? height,
    double? spacing,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
    return useGoogleFonts ? GoogleFonts.jetBrainsMono(textStyle: base) : base;
  }
}

ThemeData buildAppTheme() => ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.blue,
        onSecondary: AppColors.onAccent,
        tertiary: AppColors.pink,
        onTertiary: AppColors.onAccent,
        error: AppColors.pink,
        onError: AppColors.onAccent,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        outline: AppColors.line,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
