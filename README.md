# Eventi — iOS App (SwiftUI, MVVM, Clean Architecture)

Una app nativa para descubrir, crear y gestionar eventos, con autenticación segura, asistencias y soporte de datos *mock* para desarrollo rápido.

> **Objetivo**: entregar un producto mantenible, testeable y escalable listo para revisión técnica por recruiters.

---

## Tabla de contenidos
- [Ventajas principales](#ventajas-principales)
- [Requisitos](#requisitos)
- [Ejecución del proyecto](#ejecución-del-proyecto)
- [Estructura de navegación](#estructura-de-navegación)
- [Autenticación](#autenticación)
- [Sistema de asistencias](#sistema-de-asistencias)
- [Roadmap](#roadmap)
- [Arquitectura (iOS)](#arquitectura-ios)
- [Calidad y testing](#calidad-y-testing)
- [Rendimiento y accesibilidad](#rendimiento-y-accesibilidad)
- [Backend (resumen técnico)](#backend-resumen-técnico)
- [Seguridad y cumplimiento](#seguridad-y-cumplimiento)
- [Contacto](#contacto)

---

## Ventajas principales
- Separación clara de responsabilidades.  
- Mayor facilidad para realizar tests unitarios.  
- Mantenimiento y escalado más simples.  
- Desarrollo iterativo con datos *mock* para no depender del backend en fases tempranas.

---

## Requisitos
- iOS 18 o superior.  
- Versión actual de Xcode con soporte para SwiftUI.

---

## Ejecución del proyecto
1. Clonar el repositorio.  
2. Abrir el proyecto en Xcode.  
3. Ajustar el **Bundle Identifier** y la firma si es necesario.  
4. Ejecutar en simulador o dispositivo físico.  
5. *(Opcional)* Configurar variables del backend si se desea conectar con el servidor real.

> Por defecto, la aplicación puede ejecutarse completamente con datos *mock*.

---

## Estructura de navegación
- **Eventos**: Lista general de eventos.  
- **Nuevo evento**: Creación mediante vista modal con selectores de fecha y hora.  
- **EventiBot**: Asistente con sugerencias *(vista en desarrollo)*.  
- **Perfil**: Información del usuario y ajustes.

---

## Autenticación
- Inicio de sesión mediante **email** y **contraseña**.  
- Validación de campos en tiempo real.  
- Credenciales guardadas de forma segura en **Keychain**.  
- Estado global de sesión gestionado por `AppStateViewModel`.

---

## Sistema de asistencias
Cada usuario puede indicar su participación en un evento:
- *Asistir*  
- *No asistir*  
- *Tal vez*

El detalle del evento muestra el conteo actualizado de cada estado.

---

## Roadmap
- [ ] Integración completa de **EventiBot** con IA (texto y voz).  
- [ ] Notificaciones push para recordatorios.  
- [ ] Compartir eventos por WhatsApp, correo o calendario.  
- [ ] Autenticación biométrica (Face ID / Touch ID).  
- [ ] Geolocalización y mapas interactivos.  
- [ ] Personalización de temas y colores.

---

## Arquitectura (iOS)
- **Patrones**: **Clean Architecture** + **MVVM** sobre **SwiftUI**.  
- **Capas**:
  - **Presentation**: Vistas SwiftUI y `ViewModels` (estado y bindings).  
  - **Domain**: Casos de uso, entidades y protocolos.  
  - **Data**: Repositorios, *data sources* (remoto/local), *mappers* y *DTOs*.  
- **Principios**: inyección de dependencias, bajo acoplamiento, testabilidad.


---

## Calidad y testing
- **Unit Tests** en casos de uso y *ViewModels*.  
- **Mocks/Stubs** para repositorios y *data sources*.  
- **Previews** en SwiftUI con estados controlados.  
- *(Opcional)* **Snapshot tests** para vistas críticas.

---

## Rendimiento y accesibilidad
- Listas virtualizadas y carga perezosa.  
- Uso eficiente de `@State`, `@StateObject`, `@ObservedObject` y `@EnvironmentObject`.  
- Dinamic Type, VoiceOver y contraste de color considerados en componentes base.

---

## Backend (resumen técnico)
**Objetivo**: base sólida, segura y escalable para gestionar usuarios, eventos e intereses.

- **Tecnología**: SQLite local *(migrable a PostgreSQL)*.  
- **Estructura**: `Models`, `Controllers`, `DTOs`, `Migrations`, `Middleware`, `JWT`, `Jobs`, `Tools/Constants`.  
- **Modelos clave**:  
  - `User`: email normalizado, contraseña encriptada con **BCrypt**.  
  - `Interest` y `UserInterest`: relación N:N optimizada.  
  - `Event`: nombre, fecha, categoría, ubicación, coordenadas.  
  - `EventAttendance`: estados de asistencia.  
- **Autenticación**: Tokens **JWT** (access y refresh) y rutas protegidas.  
- **Seguridad**: claves privadas fuera del repositorio y sin credenciales en código.  
- **Migrations**: creación de entidades, pivotes y *seed* inicial.

> La aplicación puede ejecutarse sin backend para fines de demostración o desarrollo.

---

## Seguridad y cumplimiento
- Almacenamiento de credenciales en **Keychain**.  
- Comunicación *(cuando aplique)* sobre **HTTPS/TLS**.  
- Buenas prácticas OWASP Mobile: validaciones, manejo de errores y *least privilege*.  
- Variables sensibles gestionadas por esquemas/entornos y fuera del control de versiones.

---

## Decisiones técnicas
- Uso de **Clean Architecture** con **MVVM** para reducir el acoplamiento.  
- Implementación completa en **SwiftUI**, priorizando código declarativo y mantenible.  
- Datos *mock* durante el desarrollo para mejorar la iteración y el testeo sin depender de servicios externos.

---

## Contacto
- Javier Gómez — [javiergomezdev@gmail.com](mailto:javiergomezdev@gmail.com)  
- Santiago Coto — [santiagocotovila@outlook.com](mailto:santiagocotovila@outlook.com)  
- Manuel Liébana — [manololiebana@gmail.com](mailto:manololiebana@gmail.com)
