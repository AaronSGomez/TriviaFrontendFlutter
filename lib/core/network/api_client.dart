import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Auth interceptor: attaches JWT token if available
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
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
    ),
  );

  // Interceptor para manejar tokens caducados (403)
  dio.interceptors.add(AuthInterceptor(ref));

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
});
