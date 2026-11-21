abstract final class AppConstants {
  static const String appName = 'ExamGenius AI';
  static const Duration splashDelay = Duration(milliseconds: 1800);

  /// Max content width so layouts stay readable on tablets / foldables.
  static const double maxContentWidth = 640;
}

abstract final class PrefKeys {
  static const String onboardingDone = 'onboarding_done';
  static const String localeCode = 'locale_code';
  static const String themeMode = 'theme_mode';
  // NOTE: auth tokens must NOT live here. Use flutter_secure_storage when the
  // real backend is wired in (Phase 3 backend integration).
  static const String sessionUser = 'session_user';

  /// Mock-only cache of saved practice sets until the backend is live.
  static const String savedPractice = 'saved_practice_v1';
}
