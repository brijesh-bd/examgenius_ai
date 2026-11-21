import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Font-size scale. Use these instead of raw numbers.
abstract final class AppFontSizes {
  static const double xxs = 10;
  static const double xs = 11.5;
  static const double sm = 13;
  static const double md = 14;
  static const double body = 15;
  static const double lg = 16;
  static const double xl = 18;
  static const double h3 = 20;
  static const double h2 = 22;
  static const double h1 = 26;
  static const double display = 34;
  static const double hero = 44;
}

/// Font weights by intent.
abstract final class AppFontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// Google Font (Poppins) text styles. Colours are left unset unless the style
/// is brand-specific, so they inherit from the theme in light and dark mode.
abstract final class AppTextStyles {
  static TextStyle _p(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  /// Full Material text theme in Poppins (used by AppTheme).
  static TextTheme textTheme(TextTheme base) =>
      GoogleFonts.poppinsTextTheme(base);

  /// Font family name registered by google_fonts, for widgets that need it.
  static String get fontFamily => GoogleFonts.poppins().fontFamily!;

  // Headings
  static TextStyle get h1 => _p(AppFontSizes.h1, AppFontWeights.extraBold);
  static TextStyle get h2 => _p(AppFontSizes.h2, AppFontWeights.extraBold);
  static TextStyle get h3 => _p(AppFontSizes.h3, AppFontWeights.bold);

  // Body
  static TextStyle get bodyLarge => _p(AppFontSizes.lg, AppFontWeights.regular);
  static TextStyle get body => _p(AppFontSizes.md, AppFontWeights.regular);
  static TextStyle get bodySmall => _p(AppFontSizes.sm, AppFontWeights.regular);
  static TextStyle get caption =>
      _p(AppFontSizes.xs, AppFontWeights.regular, height: 1.3);

  // Labels / buttons
  static TextStyle get button => _p(AppFontSizes.lg, AppFontWeights.semiBold);
  static TextStyle get buttonSmall =>
      _p(AppFontSizes.body, AppFontWeights.semiBold);
  static TextStyle get label => _p(AppFontSizes.md, AppFontWeights.semiBold);
  static TextStyle get labelBold => _p(AppFontSizes.md, AppFontWeights.bold);
  static TextStyle get navLabel => _p(AppFontSizes.sm, AppFontWeights.medium);
  static TextStyle get tiny => _p(AppFontSizes.xxs, AppFontWeights.medium);

  // Home
  static TextStyle get greeting =>
      _p(AppFontSizes.h2, AppFontWeights.extraBold, color: AppColors.white);
  static TextStyle get greetingSub => _p(
    AppFontSizes.md,
    AppFontWeights.regular,
    color: AppColors.white.withValues(alpha: 0.92),
  );
  static TextStyle get tileTitle =>
      _p(AppFontSizes.body, AppFontWeights.extraBold, height: 1.15);

  // Brand
  static TextStyle wordmark(double size, Color color) => _p(
    size,
    AppFontWeights.bold,
    height: 1.1,
    color: color,
  ).copyWith(letterSpacing: -1);
  static TextStyle tagline(double size, Color color) =>
      _p(size, AppFontWeights.medium, height: 1.35, color: color);
  static TextStyle get chip => _p(AppFontSizes.md, AppFontWeights.semiBold);
}
