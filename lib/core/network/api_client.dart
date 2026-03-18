import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers.dart';
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
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
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
