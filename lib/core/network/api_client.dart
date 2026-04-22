import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import '../providers.dart';
import '../router/app_router.dart';
import '../security/jwt_utils.dart';
import 'auth_interceptor.dart';

String get kBaseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

final dioProvider = Provider<Dio>((ref) {
  final requestOptions = BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  final dio = Dio(requestOptions);
  final random = Random();

  String generateRequestId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final suffix = random.nextInt(1 << 20).toRadixString(16);
    return 'app-$now-$suffix';
  }

  // Auth interceptor: attaches JWT token if available
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['requestStartAt'] = DateTime.now().microsecondsSinceEpoch;
        options.headers['X-Request-Id'] ??= generateRequestId();

        final prefs = ref.read(sharedPreferencesProvider);
        final token = prefs.getString('jwt_token');

        final isAuthEndpoint = options.path.startsWith('/api/auth/');
        if (isAuthEndpoint) {
          return handler.next(options);
        }

        if (token != null && token.isNotEmpty) {
          if (isJwtExpired(token)) {
            prefs.clear();
            router.go('/');
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Token caducado. Inicia sesión de nuevo.'},
                ),
                message: 'Token caducado. Inicia sesión de nuevo.',
              ),
              true,
            );
          }

          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        }

        prefs.clear();
        router.go('/');
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'No hay sesión activa. Inicia sesión o regístrate.'},
            ),
            message: 'No hay sesión activa. Inicia sesión o regístrate.',
          ),
          true,
        );
      },
      onResponse: (response, handler) {
        final startedAt = response.requestOptions.extra['requestStartAt'] as int?;
        final elapsedMs = startedAt == null ? -1 : (DateTime.now().microsecondsSinceEpoch - startedAt) / 1000;

        if (kDebugMode) {
          debugPrint(
            '[HTTP] ${response.requestOptions.method} ${response.requestOptions.path} '
            'status=${response.statusCode} elapsedMs=${elapsedMs >= 0 ? elapsedMs.toStringAsFixed(1) : 'n/a'} '
            'requestId=${response.requestOptions.headers['X-Request-Id']}',
          );
        }

        handler.next(response);
      },
      onError: (error, handler) {
        final startedAt = error.requestOptions.extra['requestStartAt'] as int?;
        final elapsedMs = startedAt == null ? -1 : (DateTime.now().microsecondsSinceEpoch - startedAt) / 1000;

        if (kDebugMode) {
          debugPrint(
            '[HTTP-ERR] ${error.requestOptions.method} ${error.requestOptions.path} '
            'status=${error.response?.statusCode} elapsedMs=${elapsedMs >= 0 ? elapsedMs.toStringAsFixed(1) : 'n/a'} '
            'type=${error.type} requestId=${error.requestOptions.headers['X-Request-Id']} '
            'message=${error.message}',
          );
        }

        handler.next(error);
      },
    ),
  );

  // Interceptor para manejar tokens caducados (403)
  dio.interceptors.add(AuthInterceptor(ref));

  // Logging solo en modo debug para evitar bloqueos de UI en Android
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  return dio;
});
