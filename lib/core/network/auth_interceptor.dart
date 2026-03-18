import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../../features/auth/auth_controller.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 403) {
      // 1. Limpiar la sesión completa (Token y estado del Player)
      // Usamos el controller para asegurar que se limpia tanto SharedPreferences como el estado en memoria
      ref.read(authControllerProvider.notifier).logout();

      // 2. Ejecutar la Redirección al Login borrando el historial
      router.go('/');
    }

    // Continuar con el error para que la aplicación lo pueda gestionar también
    super.onError(err, handler);
  }
}
