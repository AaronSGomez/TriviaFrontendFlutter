# Flujo de Autenticación Firebase - Trivia App

## ✅ IMPLEMENTADO: Vinculación Correcta a Firebase

El código Dart ahora sigue el flujo correcto para que los usuarios aparezcan en **Firebase Console**:

### El Flujo (5 Pasos)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario toca "Continuar con Google"                      │
│    (WelcomeScreen -> signInWithGoogle)                      │
└───────────────────────┬─────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Google Sign-In                                           │
│    - Web: attemptLightweightAuthentication()               │
│    - Mobile: authenticate()                                 │
│    ➜ Devuelve: GoogleSignInAccount (con credenciales)      │
└───────────────────────┬─────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. NUEVO: Registrar en Firebase Auth                        │
│    A. Obtener accessToken + idToken de Google              │
│    B. Crear GoogleAuthProvider.credential(...)             │
│    C. FirebaseAuth.instance.signInWithCredential()         │
│    ➜ El usuario aparece en Firebase Console                │
│    ➜ Devuelve: UserCredential con Firebase User            │
└───────────────────────┬─────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. NUEVO: Obtener Token de Firebase                         │
│    D. userCredential.user?.getIdToken()                    │
│    ➜ Token de Firebase (no de Google!)                     │
└───────────────────────┬─────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Enviar Token a Backend Java                              │
│    E. POST /api/auth/google { idToken: <FIREBASE_TOKEN> }  │
│    ➜ Backend valida con Google y crea/actualiza Player     │
│    ➜ Devuelve: JWT + Player data                           │
└───────────────────────┬─────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Guardar Sesión Local                                     │
│    - Guardar JWT + Player data en SharedPreferences        │
│    - Actualizar UI (ir a Dashboard)                         │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Código Clave

### Ubicación: `lib/features/auth/auth_controller.dart`

**Método principal:**
```dart
Future<void> signInWithGoogle() async {
  // Llama a uno de estos según plataforma:
  // - Web: attemptLightweightAuthentication()
  // - Mobile: authenticate()
  
  // Luego ambos llaman:
  await _authenticateAndRegisterWithFirebase(googleUser);
}

/// El flujo completo de 5 pasos
Future<void> _authenticateAndRegisterWithFirebase(GoogleSignInAccount googleUser) async {
  // A. Obtener credenciales de Google
  // B. Crear credencial para Firebase
  // C. Registrar en Firebase (vincula a Firebase)
  // D. Obtener token de Firebase
  // E. Enviar al backend
}
```

## 🔄 Cambios desde la versión anterior

### Antes:
```dart
// ❌ INCORRECTO: Enviaba directamente el token de Google
final idToken = googleAuth.idToken;
await repository.loginWithGoogle(idToken); // Token de Google
```

### Ahora:
```dart
// ✅ CORRECTO: Registra en Firebase y envía su token
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
String firebaseIdToken = await userCredential.user?.getIdToken();
await repository.loginWithGoogle(firebaseIdToken); // Token de Firebase
```

## 🎯 Verificación en Firebase Console

Después de que un usuario haga login:

1. Ve a **[Firebase Console](https://console.firebase.google.com)**
2. Selecciona tu proyecto
3. Ve a **Authentication > Users**
4. ✅ Deberías ver al usuario listado aquí
5. Haz click en él para ver:
   - Email
   - Provider: Google
   - Fecha de creación
   - Last sign-in

## 🚀 Backend (Java)

El backend en `/api/auth/google` ahora recibe un token de **Firebase**, no de Google.

El endpoint sigue igual:
```java
@PostMapping("/google")
public ResponseEntity<AuthenticationResponse> googleLogin(
    @Valid @RequestBody GoogleAuthRequest request) {
  // request.getIdToken() = Firebase ID Token
  var authenticated = authUseCase.loginWithGoogle(request.getIdToken());
  // ...
}
```

**Nota:** El backend valida el token con Google, pero ahora recibe un token válido de Firebase que también contiene la info de Google.

## 📱 Plataformas Soportadas

| Plataforma | Método | Estado |
|-----------|--------|--------|
| Web | `attemptLightweightAuthentication()` | ✅ Implementado |
| Android | `authenticate()` + Firebase Auth | ✅ Implementado |
| iOS | `authenticate()` + Firebase Auth | ✅ Implementado |
| Windows | ❌ No soportado | ✅ Mensaje claro |
| macOS | `authenticate()` + Firebase Auth | ✅ Implementado |
| Linux | `authenticate()` + Firebase Auth | ✅ Implementado |

## 🐛 Debugging

Si algo sale mal, verifica en la consola Flutter:

```
[GoogleAuth] Step A: Obtaining Google credentials...
[GoogleAuth] Step B: Creating Firebase credential...
[GoogleAuth] Step C: Signing in with Firebase...
[GoogleAuth] Firebase user linked: user@gmail.com
[GoogleAuth] Step D: Getting Firebase ID Token...
[GoogleAuth] Step E: Sending Firebase token to backend...
```

Cada línea representa un paso exitoso del flujo.
