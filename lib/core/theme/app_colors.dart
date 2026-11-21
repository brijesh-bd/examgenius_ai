import 'package:flutter/material.dart';

/// Single source of truth for every colour in ExamGenius AI.
///
/// Prefer Material roles via `Theme.of(context).colorScheme` where one fits;
/// use these constants for brand accents. Never write `Color(0x…)` outside
/// this file.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryVariant = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color navy = Color(0xFF1E2A78); // headings
  static const Color brandBlue = Color(0xFF1546C8); // "ExamGenius" wordmark
  static const Color accent = Color(0xFF7C3AED); // AI / premium
  static const Color accentLight = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFFF59E0B); // highlights
  static const Color gold = Color(0xFFFBBF24); // logo book, star
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = secondary;

  // ── Neutrals ───────────────────────────────────────────────────────────
  static const Color white = Colors.white;
  static const Color textMuted = Color(0xFF4B5470);
  static const Color divider = Color(0xFF5B6382);
  static const Color surface = Color(0xFFF3F4F6);
  static const Color lightScaffold = Color(0xFFF8FAFF);
  static const Color darkPrimary = Color(0xFF8AB4FF);
  static const Color darkSecondary = Color(0xFFB79CFF);
  static const Color darkSurface = Color(0xFF0F1420);
  static const Color darkScaffold = Color(0xFF0A0E17);
  static const Color darkInputFill = Color(0xFF161C2A);
  static const Color darkTint = Color(0xFF16213A);
  static const Color lightTint = Color(0xFFEAF1FF);
  static const Color authHeaderLight = Color(0xFFDCE8FF);
  static const Color cardShadow = Color(0x0F1E3A8A);

  // ── Auth ──────────────────────────────────────────────────────────────
  static const Color headline = Color(0xFF0B1A3A);
  static const Color fieldBorder = Color(0xFFD3D8E6);
  static const LinearGradient loginButton = LinearGradient(
    colors: [Color(0xFF1565F0), Color(0xFF2A3FE0)],
  );

  // ── Exam categories ────────────────────────────────────────────────────
  static const Color railway = Color(0xFF1E6BF0);
  static const Color ssc = Color(0xFFF7820F);
  static const Color banking = Color(0xFF16A34A);

  // ── Home module tiles ──────────────────────────────────────────────────
  static const Color mockTests = Color(0xFF7C3AED);
  static const Color dailyPractice = Color(0xFFEC2C5B);
  static const Color previousYear = Color(0xFF0EA5B7);

  /// Cycled for syllabus subject / topic cards.
  static const List<Color> subjectPalette = [
    Color(0xFF1E6BF0),
    Color(0xFF7C3AED),
    Color(0xFF16A34A),
    Color(0xFFF7820F),
    Color(0xFFEC2C5B),
    Color(0xFF0EA5B7),
  ];

  // ── Splash illustration ────────────────────────────────────────────────
  static const Color splashBgTop = Color(0xFFF4F6FF);
  static const Color splashBgBottom = Color(0xFFFFFFFF);
  static const Color splashCloud = Color(0xFFE6EAFA);
  static const Color leafGreen = Color(0xFF22C55E);
  static const Color leafDark = Color(0xFF15803D);
  static const Color bookOrange = Color(0xFFF97316);
  static const Color pageWhite = Color(0xFFF8FAFC);
  static const Color laptopFrame = Color(0xFF1E3A8A);
  static const Color laptopBase = Color(0xFFCBD5E1);
  static const Color clipLine = Color(0xFFD5DCEC);

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accent],
  );

  static const LinearGradient aiBadgeGradient = LinearGradient(
    colors: [accentLight, accent],
  );

  /// Blue → purple corner waves on the splash.
  static const LinearGradient splashWave = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3B82F6), Color(0xFF6D4AF5), Color(0xFFA855F7)],
  );

  static const LinearGradient splashWaveSoft = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7DB4FF), Color(0xFFC4A5FF)],
  );

  /// Laptop screen with the AI chip.
  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFFC084FC)],
  );

  /// Logo book page layers, outer → inner.
  static const List<Color> logoPages = [primaryDark, primary, primaryLight];
}
