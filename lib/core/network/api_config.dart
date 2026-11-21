import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend base URL. Override at build/run time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api/v1
/// Defaults: Android emulator → `10.0.2.2` (the PC's localhost as seen from
/// the emulator); web/desktop → `localhost`. A physical phone needs the PC's
/// Wi-Fi IP via API_BASE_URL (phone and PC on the same network).
const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

String get kApiBaseUrl {
  if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
  return 'http://localhost:3000/api/v1';
}

/// AI generation can take a while when Gemini is busy (the backend tries
/// several models), so generation gets a long timeout.
const Duration kApiTimeout = Duration(seconds: 30);
const Duration kGenerateTimeout = Duration(minutes: 3);

/// true → in-app mock repositories (no server). Used automatically by
/// `flutter test`, or on demand with `--dart-define=USE_MOCK_BACKEND=true`.
final useMockBackendProvider = Provider<bool>((ref) {
  const forced = bool.fromEnvironment('USE_MOCK_BACKEND');
  final underTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
  return forced || underTest;
});
