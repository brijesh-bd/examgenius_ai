import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend base URL. Default `127.0.0.1:3000` everywhere.
///
/// Android (USB phone or emulator): forward the device's port to the PC once
/// per connection —  `adb reverse tcp:3000 tcp:3000`  — then the app reaches
/// the server on the PC through the cable (no Wi-Fi / firewall setup).
///
/// Or point at the PC over Wi-Fi instead:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api/v1
const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

String get kApiBaseUrl => _definedBaseUrl.isNotEmpty
    ? _definedBaseUrl
    : 'http://127.0.0.1:3000/api/v1';

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
