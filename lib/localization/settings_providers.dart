import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/services/preferences_service.dart';

const supportedLocales = [Locale('en'), Locale('hi')];

/// App-wide selected language. Persisted so it survives restarts.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref
        .read(sharedPreferencesProvider)
        .getString(PrefKeys.localeCode);
    return Locale(code ?? 'en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(PrefKeys.localeCode, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final name = ref
        .read(sharedPreferencesProvider)
        .getString(PrefKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(PrefKeys.themeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
