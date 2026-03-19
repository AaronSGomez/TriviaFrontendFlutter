import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../router/app_router.dart';
import '../../features/auth/auth_controller.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      // Limpiamos sesión y obligamos a autenticación de nuevo.
      unawaited(ref.read(authControllerProvider.notifier).logout());

      router.go('/');
    }

    // Continuar con el error para que la aplicación lo pueda gestionar también
    super.onError(err, handler);
  }
}
