import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'token_store.dart';

/// Failure from the backend, with the server's message when it sent one.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetwork = false,
    this.code,
    this.details = const {},
  });

  final String message;
  final int? statusCode;

  /// No response at all (server down, wrong IP, no internet, timeout).
  final bool isNetwork;

  /// Machine-readable reason from the server, e.g. `DAILY_SETS`, `SET_SIZE`.
  final String? code;
  final Map<String, dynamic> details;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Thin wrapper over Dio: base URL, bearer token, JSON, error mapping.
class ApiClient {
  ApiClient(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  /// Called when an authenticated request gets 401 (expired/invalid token).
  void Function()? onUnauthorized;

  factory ApiClient.create(TokenStore tokens, {String? baseUrl}) => ApiClient(
        Dio(BaseOptions(
          baseUrl: baseUrl ?? kApiBaseUrl,
          connectTimeout: kApiTimeout,
          receiveTimeout: kApiTimeout,
          sendTimeout: kApiTimeout,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        )),
        tokens,
      );

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, [Object? body, Duration? timeout]) =>
      _send('POST', path, body: body, timeout: timeout);

  Future<Map<String, dynamic>> patch(String path, [Object? body]) =>
      _send('PATCH', path, body: body);

  Future<void> delete(String path) => _send('DELETE', path);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    Duration? timeout,
  }) async {
    final token = _tokens.token;
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(
          method: method,
          receiveTimeout: timeout,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      final data = res.data;
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 && token != null) onUnauthorized?.call();
      final data = e.response?.data;
      final serverMsg = data is Map && data['error'] is String ? data['error'] as String : null;
      final noResponse = e.response == null;
      throw ApiException(
        serverMsg ?? (noResponse ? 'Cannot reach the ExamGenius server' : 'Request failed'),
        statusCode: status,
        isNetwork: noResponse,
        code: data is Map && data['code'] is String ? data['code'] as String : null,
        details: data is Map && data['details'] is Map
            ? Map<String, dynamic>.from(data['details'] as Map)
            : const {},
      );
    }
  }
}

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient.create(ref.watch(tokenStoreProvider)),
);
