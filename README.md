# Our Story

Aplicación móvil para parejas para compartir momentos, notas y mensajes.

## Stack Tecnológico

### Backend
- **Spring Boot 3.5.7** con Java 17
- **PostgreSQL 17** como base de datos
- **Firebase Storage** para almacenamiento de archivos
- **JWT** para autenticación
- **WebSocket** para mensajería en tiempo real
- **Docker** para contenedorización

### Frontend
- **Flutter** para desarrollo multiplataforma
- Arquitectura limpia con providers

## Configuración de Variables de Entorno

### Opción 1: Archivo `.env` (Desarrollo Local)

1. Copia el archivo de ejemplo:
```bash
cd our-story-back
cp .env.example .env
```

2. Edita `.env` con tus credenciales reales:
```env
# Database
POSTGRES_PASSWORD=tu_password_seguro

# JWT (genera una clave segura)
JWT_SECRET_KEY=$(openssl rand -base64 64)

# Firebase (usa variables de entorno - RECOMENDADO)
FIREBASE_PROJECT_ID=tu-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\ntu-clave-privada\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=tu-email@tu-proyecto.iam.gserviceaccount.com
FIREBASE_BUCKET_NAME=tu-bucket.firebasestorage.app
```

### Opción 2: Archivo `serviceAccountKey.json` (Alternativa)

Si prefieres usar el archivo JSON de Firebase:

1. Descarga `serviceAccountKey.json` desde Firebase Console
2. Colócalo en `our-story-back/firebase/serviceAccountKey.json`
3. En `.env`, comenta las variables de Firebase y descomenta:
```env
FIREBASE_CREDENTIALS_PATH=firebase/serviceAccountKey.json
```

**IMPORTANTE:** El archivo `serviceAccountKey.json` NUNCA debe subirse a git. Está protegido en `.gitignore`.

## Ejecución con Docker

### 1. Construir el backend

```bash
cd our-story-back
./mvnw clean package -DskipTests
```

### 2. Levantar servicios

```bash
docker-compose up -d
```

Esto levantará:
- PostgreSQL en puerto 5432
- Backend en puerto 8080

### 3. Ver logs

```bash
docker-compose logs -f app
```

### 4. Detener servicios

```bash
docker-compose down
```

## Ejecución sin Docker

### Backend

```bash
# 1. Iniciar PostgreSQL
docker-compose up -d db

# 2. Ejecutar aplicación
cd our-story-back
./mvnw spring-boot:run
```

### Frontend

```bash
cd our_story_front

# Ejecutar en Android/iOS
flutter run

# Actualizar IP del backend (si usas dispositivo físico)
../update_ip.sh
```

## Comandos Útiles

### Backend

```bash
# Tests
./mvnw test

# Test específico
./mvnw test -Dtest=ClassName#methodName

# Limpiar y construir
./mvnw clean install

# Solo compilar sin tests
./mvnw clean package -DskipTests
```

### Frontend

```bash
# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Construir APK
flutter build apk

# Ejecutar tests
flutter test
```

## Arquitectura del Backend

```
com.ourstory.our_story_back/
├── config/          # Configuración (Security, Firebase, CORS, WebSocket)
├── controller/      # Controladores REST
├── dto/             # DTOs de request/response
├── entity/          # Entidades JPA
├── enums/           # Enumeraciones
├── exceptions/      # Manejo global de excepciones
├── mapper/          # Mappers de Entity <-> DTO
├── repository/      # Repositorios JPA
└── service/         # Lógica de negocio
```

## Endpoints Principales

- `/api/auth/*` - Autenticación y registro
- `/api/users/*` - Gestión de usuarios
- `/api/couples/*` - Gestión de parejas
- `/api/dates/*` - Gestión de citas
- `/api/notes/*` - Gestión de notas
- `/api/messages/*` - Mensajería
- `/api/pairing/*` - Emparejamiento de parejas

## Seguridad

### Archivos Protegidos (no en git)

- `.env` - Variables de entorno
- `firebase/serviceAccountKey.json` - Credenciales de Firebase
- Archivos de documentación innecesarios

### Mejores Prácticas Implementadas

1. **Variables de entorno** para todos los secretos
2. **`.gitignore`** completo en raíz y subdirectorios
3. **`.env.example`** como plantilla sin secretos
4. **Firebase con variables de entorno** en lugar de archivo JSON
5. **Dockerfile** optimizado con Eclipse Temurin 17
6. **docker-compose** con healthchecks y networks

## Notas para Producción

### Antes de Desplegar

1. **Rotar secretos:**
   ```bash
   # Generar nuevo JWT secret
   openssl rand -base64 64
   
   # Regenerar credenciales de Firebase en Firebase Console
   ```

2. **Variables de entorno en servidor:**
   - Usar secrets managers (AWS Secrets Manager, GCP Secret Manager, etc.)
   - O variables de entorno del sistema operativo
   - Nunca hardcodear en código

3. **Base de datos:**
   - Usar base de datos externa (no Docker en producción)
   - Configurar backups automáticos
   - Usar contraseñas fuertes

## Troubleshooting

### Error: "Firebase credentials not configured"

Verifica que tengas configurado o bien:
- Variables de entorno: `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL`
- O archivo: `FIREBASE_CREDENTIALS_PATH` apuntando a `serviceAccountKey.json`

### Error: "Connection refused" en Flutter

Actualiza la IP del backend:
```bash
./update_ip.sh
```

### Docker: Error al construir imagen

Verifica que hayas compilado el JAR primero:
```bash
cd our-story-back
./mvnw clean package -DskipTests
```

## Contribuir

1. Nunca commitear archivos `.env` o `serviceAccountKey.json`
2. Seguir las convenciones de código en `AGENTS.md`
3. Ejecutar tests antes de hacer commit
4. Usar mensajes de commit descriptivos

## Licencia

Proyecto privado - Todos los derechos reservados
