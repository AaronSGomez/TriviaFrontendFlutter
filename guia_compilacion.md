# Guía de Compilación de LevelUp42 Trivia

Esta guía explica cómo ejecutar y compilar las dos versiones diferentes de la aplicación (Estudiante y Administrador) utilizando variables de entorno de Flutter (`--dart-define`).

## Concepto Base
La aplicación utiliza la constante `IS_ADMIN` para determinar qué pestañas mostrar.
*   Si `IS_ADMIN` es `true`, se muestra la pestaña "Aportar" (Modo Administrador/Profesor).
*   Si `IS_ADMIN` es `false` (o no se especifica), se oculta la pestaña "Aportar" (Modo Estudiante).

## Configuración Inicial (.env)
Antes de compilar o ejecutar el proyecto, es necesario crear un archivo `.env` en la raíz de `TriviaFrontendFlutter`. Este archivo no se sube al repositorio por seguridad.

Crea un archivo llamado `.env` y añade la URL base de tu backend:
```env
BASE_URL=https://tu-backend-url.com
```
*(Si pruebas en local o emulador, usa `BASE_URL=http://localhost:8080` o `BASE_URL=http://10.0.2.2:8080` respectivamente).*

---

## 👨‍🎓 Versión Estudiante (Usuarios normales)
Esta es la versión por defecto. Los estudiantes solo podrán acceder a las pestañas "Jugar" y "Ranking".

**Para ejecutar en el emulador o dispositivo conectado:**
```bash
flutter run
```

**Para compilar la aplicación final:**
*   **Android (APK):** `flutter build apk`
*   **Android (AppBundle para Play Store):** `flutter build appbundle`
*   **Windows:** `flutter build windows`
*   **Web:** `flutter build web`

---

## 👨‍🏫 Versión Administrador (Profesores)
Esta versión incluye la pestaña "Aportar" para poder insertar nuevas preguntas en la base de datos. Se debe inyectar la variable `IS_ADMIN=true` al comando de Flutter.

**Para ejecutar en el emulador o dispositivo conectado durante el desarrollo:**
```bash
flutter run --dart-define=IS_ADMIN=true
```

**Para compilar la aplicación final con acceso total:**
*   **Android (APK):** `flutter build apk --dart-define=IS_ADMIN=true`
*   **Windows:** `flutter build windows --dart-define=IS_ADMIN=true`
*   **Web:** `flutter build web --dart-define=IS_ADMIN=true`

---
> **💡 Nota:** Si configuras comandos en VS Code o Android Studio, asegúrate de añadir `--dart-define=IS_ADMIN=true` en los argumentos de ejecución (Run/Debug Configurations) si deseas desarrollar y probar la funcionalidad de añadir preguntas directamente desde tu IDE sin usar la consola.
