# 🎮 TriviaHex Frontend

¡Bienvenido al frontend de **TriviaHex**! Una aplicación interactiva de preguntas y respuestas (Trivia) construida con **Flutter**. 

Este proyecto está diseñado para ser dinámico y fácil de usar, conectándose a una API backend (Spring Boot) para gestionar las partidas, los jugadores y las preguntas.

---

## ✨ Características Principales

*   **🏆 Sistema de Partidas:** Únete a sesiones de juego en tiempo real aportando tu nombre.
*   **📊 Ranking en Vivo:** Visualización clara de las puntuaciones y nombres de todos los jugadores de la sesión.
*   **⏱️ Preguntas con Temporizador:** Sistema de cuenta atrás en cada pregunta para darle emoción al juego.
*   **🎨 Diseño Atractivo:** Interfaz gráfica moderna y oscura ("Dark Theme"), con tipografía personalizada (Google Fonts), vibraciones hápticas (Vibration) y transiciones fluidas.
*   **📱 Multiplataforma:** Preparado para funcionar tanto en dispositivos móviles (iOS/Android) como en Web.
*   **🔒 Configuración Segura:** Uso de variables de entorno (`.env`) para gestionar la conexión con la API y ocultar URLs sensibles.

---

## 🚀 Tecnologías y Paquetes Clave

*   **Flutter & Dart:** Base del proyecto.
*   **Riverpod (`flutter_riverpod`):** Para la gestión de estados globales y reactivos.
*   **Dio:** Cliente HTTP robusto para la comunicación con el backend (API REST).
*   **GoRouter:** Sistema de navegación moderno y por URLs.
*   **Freezed & Json Serializable:** Para la generación de código y el manejo seguro de datos JSON (DTOs) recibidos de la API.

---

## 🛠️ Cómo Usar (Instalación y Arranque)

Sigue estos pasos para compilar y probar el proyecto en tu máquina local:

### 1. Requisitos Previos
*   Tener instalado el **Flutter SDK** (versión `^3.10.7` o superior).
*   Tener un editor de código como VS Code o Android Studio.

### 2. Clonar el repositorio
```bash
git clone https://github.com/AaronSGomez/TriviaFrontendFlutter.git
cd TriviaFrontendFlutter
```

### 3. Configurar variables de entorno (.env)
Este proyecto requiere un archivo `.env` en la raíz (junto al `pubspec.yaml`) para conectarse al backend.
1. Crea un archivo llamado exactamente `.env`.
2. Añade la URL de tu API. Por ejemplo:
```env
# Para desarrollo local con emulador
BASE_URL=http://localhost:8080

# O la URL de producción, os solicitame acceso a mi API en java spring boot con arquitectura hexagonal.
# BASE_URL=https://tu-api-en-produccion.com
```

### 4. Instalar dependencias
```bash
flutter pub get
```

### 5. Generar archivos de código (Freezed / JSON)
El proyecto utiliza generación de código. Si cambias algún modelo, o es tu primera vez clonando el proyecto, debes ejecutar:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Ejecutar la aplicación
Puedes correr el proyecto en Web o en un emulador:
```bash
flutter run
```

---

> 💡 **Nota de Desarrollo:** Este proyecto forma parte de un ecosistema que incluye un backend en Java Spring Boot usando Arquitectura Hexagonal.
