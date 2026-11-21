import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the JWT. "Remember me" → encrypted secure storage (survives
/// restarts); otherwise memory only. Never stored in SharedPreferences.
class TokenStore {
  TokenStore(this._storage, {String? initialToken}) : _token = initialToken;

  static const _key = 'auth_token';
  final FlutterSecureStorage _storage;
  String? _token;

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Reads a remembered token at app start (call before runApp).
  static Future<TokenStore> load([FlutterSecureStorage storage = const FlutterSecureStorage()]) async {
    String? saved;
    try {
      saved = await storage.read(key: _key);
    } on Object {
      saved = null; // keystore unavailable/corrupt → treat as logged out
    }
    return TokenStore(storage, initialToken: saved);
  }

  Future<void> save(String token, {required bool remember}) async {
    _token = token;
    try {
      if (remember) {
        await _storage.write(key: _key, value: token);
      } else {
        await _storage.delete(key: _key);
      }
    } on Object {
      // Secure storage failure: keep the in-memory session working.
    }
  }

  Future<void> clear() async {
    _token = null;
    try {
      await _storage.delete(key: _key);
    } on Object {
      // ignore
    }
  }
}

/// Overridden in main.dart with the loaded store; tests get an empty one.
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(const FlutterSecureStorage()),
);
