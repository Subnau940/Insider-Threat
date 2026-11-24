/// Design tokens from the prototype (calm neon: navy, electric blue, violet,
/// red). Re-skinning the app starts here.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/models.dart';

abstract final class AppColors {
  static const bg = Color(0xFF090B1A);
  static const surface = Color(0xFF12163A);
  static const line = Color(0xFF272C5A);
  static const text = Color(0xFFEEF1FF);
  static const textSoft = Color(0xFFC9D0F5);
  static const muted = Color(0xFF9AA4D6);
  static const blue = Color(0xFF5B8CFF);
  static const blueSoft = Color(0xFF9DB6FF);
  static const violet = Color(0xFF9B6BFF);
  static const red = Color(0xFFFF4D6A);
  static const redSoft = Color(0xFFFF9DAE);
  static const purple = Color(0xFFA97BFF);
  static const onAccent = Color(0xFF070A1C);
  static const disabledBg = Color(0xFF171B3C);
  static const disabledText = Color(0xFF7580B5);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, violet],
  );
  static const redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red, Color(0xFFC455FF)],
  );

  static Color team(Team t) => switch (t) {
        Team.red => red,
        Team.blue => blue,
        Team.purple => purple,
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
        primary: AppColors.blue,
        secondary: AppColors.violet,
        error: AppColors.red,
        surface: AppColors.surface,
        onSurface: AppColors.text,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
