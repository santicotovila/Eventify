# Eventify 

Una aplicación moderna de gestión de eventos desarrollada en SwiftUI siguiendo principios de Clean Architecture y SOLID. La aplicación permite a los usuarios crear, gestionar y participar en eventos de manera intuitiva,como extra que la hace unica dispone de un asistente de IA que crea sugerencias personalizadas en base a tus intereses, todo desde  una experiencia de usuario optimizada.

##  Características Principales

-  **Gestión Completa de Eventos**: Crear, editar y visualizar eventos con detalles completos
-  **Interfaz Moderna**: UI diseñada con SwiftUI y degradados personalizados
-  **Autenticación Segura**: Login seguro con almacenamiento en Keychain
- �**Sistema de Asistencias**: Votar "Asistir", "No Asistir" o "Tal vez" a eventos
-  **EventiBot**: En proceso de implementación.
-  **Arquitectura**: MVVM + Clean Architecture

### Requisitos
- iOS 18.5

##  Funcionalidades Implementadas en Front End

### 🔐 Autenticación
- [x] Login con email/password
- [x] Validación en tiempo real
- [x] Persistencia segura en Keychain
- [x] Persistencia en servidor (SQLite)
- [x] Estado global de autenticación (AppStateVM)

### 📅 Gestión de Eventos
- [x] **Lista de eventos** con diseño moderno
- [x] **Crear evento con date/time pickers** 
- [x] Separación de eventos próximos y pasados
- [x] Navegación fluida entre pantallas

### Interfaz de Usuario
- [x] **TabView con navegación inteligente**
  - Tab 1: Lista de Eventos
  - Tab 2: Crear Evento (modal)
  - Tab 3: EventiBot (modal animado)
  - Tab 4: Perfil de usuario
- [x] **Degradados modernos** en toda la app
- [x] **Animaciones del logo** en EventiBot
- [x] **Modales nativos** para date/time selection

###  Sistema de Asistencias
- [x] Votar "Asistir", "No Asistir", "Tal vez"
- [x] Visualización de respuestas en EventDetailView

## 🎯 Decisiones Técnicas

### ¿Por qué Clean Architecture + MVVM?
- **Separación clara**: Views, ViewModels, UseCases, Repositories, Network
- **Testabilidad**: Cada capa se puede testear independientemente
- **Mantenibilidad**: Cambios en una capa no afectan otras
- **Escalabilidad**: Fácil agregar nuevas funcionalidades

### ¿Por qué SwiftUI?
- **Declarativo**: UI más predecible y fácil de mantener
- **Reactive**: Binding automático entre ViewModels y Views
- **Nativo**: Performance optimizada y APIs modernas

### ¿Por qué Mock Data en JSON?
- **Desarrollo rápido**: Muy útil para pruebas
- **Fácil modificación**: JSON files editables

##  Próximos Pasos

### Prioridad Alta
- [ ] **EventiBot IA**: Chat inteligente para crear eventos por voz/texto
 - **Notificaciones Push**: Recordatorios de eventos próximos

### Prioridad Media 
- [ ] **Compartir Eventos**: Invitaciones por WhatsApp/Email/Calendar
- [ ] **Autenticación Biométrica**: Face ID / Touch ID
- [ ] - [ ] **Geolocalización**: Mapas integrados para ubicaciones  

### Prioridad Baja
- [ ] **Temas Personalizables**


##  Funcionalidades Implementadas en Server Side

🧠 Backend de Eventify
El backend de Eventify ha sido diseñado con un enfoque en orden, seguridad y escalabilidad, garantizando un mantenimiento sencillo y un entorno sólido para la gestión de usuarios, eventos e intereses.
⚙️ Estructura del Proyecto
Tools (Constants): Define constantes globales para unificar valores y evitar conflictos.
Models: Contiene las entidades principales y sus relaciones.
Migrations: Se encargan de crear, modificar o revertir tablas en la base de datos.
Middleware: Gestiona validaciones y seguridad de acceso.
JWT: Implementa la autenticación mediante tokens seguros.
Jobs: Pensados para tareas en segundo plano, como la doble autenticación (en producción).
DTOs (Data Transfer Objects): Validan y transfieren datos entre las capas del sistema.
Controllers: Controlan las rutas y la lógica de negocio.
🧩 Modelos Principales
User: Representa a los usuarios. Campos: id, nombre, email (en minúsculas para evitar duplicados) y password (encriptada con BCrypt).
Interest: Define los intereses con atributos id y nombre, y un método para limpiar el texto (sin tildes o mayúsculas).
UserInterest: Tabla intermedia que relaciona usuarios e intereses.
Event: Representa los eventos creados por los usuarios, con datos como nombre, fecha, categoría, dirección, latitud, longitud y localización.
EventAttendance: Relaciona usuarios y eventos, con estados como Asistir, No asistir y Pendiente.
🗃️ Migrations
create-users – Tabla de usuarios.
create-interest – Tabla de intereses.
create-user-interest – Tabla pivote usuario/interés.
create-events – Tabla de eventos.
create-event-attendances – Tabla de asistencias.
populate-date – Inserción inicial de intereses disponibles.
🧱 Middleware
AdminMiddleware: Control de permisos administrativos (pendiente de implementación).
ApiKeyMiddleware: Verifica la API Key del servidor.
🔐 Autenticación (JWT)
Gestión completa de access tokens y refresh tokens:
Creación, validación y expiración de tokens.
Protección total de rutas privadas.
⚙️ Controladores
UsersController: Obtiene, detalla o elimina usuarios.
AuthController: Registra y autentica usuarios.
InterestsController: CRUD completo de intereses.
EventsController: CRUD de eventos.
EventsAttendeesController: Gestiona asistencias (confirmar, rechazar o pendiente).
JWTUserAuthenticator: Verifica tokens y busca usuarios en la base de datos.
🧾 DTOs (Data Transfer Objects)
Cada DTO valida y estructura los datos que viajan entre cliente y servidor:
UserDTO, InterestDTO, UserInterestDTO, EventDTO, EventAttendeesDTO, TokenDTO.
🛢️ Base de Datos
SQLite: En entorno local.
PostgreSQL: Preparado para despliegue en producción.
🛡️ Seguridad
Claves privadas fuera del repositorio.
Nunca se exponen credenciales en GitHub.
Proyecto en fase de pruebas con visión a un entorno seguro de producción.

## 📞 Contacto

**Javier Gómez** - javiergomezdev@gmail.com
**Santiago Coto** - santiagocotovila@outlook.com
**Manuel Liebana** - manololiebana@gmail.com
