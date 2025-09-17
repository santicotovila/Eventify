# EventifyAI 🎯

Una aplicación moderna de gestión de eventos desarrollada en SwiftUI siguiendo principios de Clean Architecture y SOLID. La aplicación permite a los usuarios crear, gestionar y participar en eventos de manera intuitiva, con date/time pickers completamente funcionales y una experiencia de usuario optimizada.

## ✨ Características Principales

- 📅 **Gestión Completa de Eventos**: Crear, editar y visualizar eventos con detalles completos
- 🎨 **Interfaz Moderna**: UI diseñada con SwiftUI y degradados personalizados
- 📱 **Date/Time Pickers Funcionales**: Selección intuitiva de fechas y horas con modales nativos ✅
- 🔐 **Autenticación Segura**: Login seguro con almacenamiento en Keychain
- 💬 **Sistema de Asistencias**: Votar "Asistir", "No Asistir" o "Tal vez" a eventos
- 🤖 **EventiBot Modal**: Animación del logo con efectos visuales (próximamente IA)
- 📊 **Datos Mock Completos**: 6 eventos, 9 usuarios y 15 respuestas de asistencia (fechas 2025)
- 🏗️ **Arquitectura Limpia**: MVVM + Clean Architecture + Repository Pattern

## 🚀 Instalación Rápida

### Requisitos
- iOS 18.5+
- Xcode 16.0+
- Swift 5.9+
- macOS Sonoma 14.0+

### Pasos

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/EventifyAI.git
cd EventifyAI
```

2. **Abrir proyecto**
```bash
open Eventify/Eventify/EventifyAI.xcodeproj
```

3. **Credenciales de prueba**
```bash
Email: demo@eventify.com
Password: cualquier_password
```

4. **Ejecutar en simulador**
```bash
# En Xcode: cmd + R
# Seleccionar iPhone 16 o simulador disponible
```

## 🏗️ Arquitectura

EventifyAI sigue una arquitectura limpia (Clean Architecture) con separación clara de responsabilidades:

```
┌─────────────────┐
│   Presentation  │ ← SwiftUI Views, ViewModels (MVVM)
├─────────────────┤
│     Domain      │ ← Models, Use Cases, Protocols
├─────────────────┤
│      Data       │ ← Repositories, JSON Mock Data
├─────────────────┤
│   Infrastructure│ ← Keychain, Local Storage
└─────────────────┘
```

## ✅ Funcionalidades Implementadas

### 🔐 Autenticación
- [x] Login con email/password
- [x] Validación en tiempo real
- [x] Almacenamiento seguro en Keychain
- [x] Estado global de autenticación (AppStateVM)

### 📅 Gestión de Eventos
- [x] **Lista de eventos** con diseño moderno
- [x] **Crear evento con date/time pickers funcionales** ✅
- [x] **EventDetailView con carga automática** ✅
- [x] Separación de eventos próximos y pasados
- [x] Navegación fluida entre pantallas

### 🎨 Interfaz de Usuario
- [x] **TabView con navegación inteligente**
  - Tab 1: Lista de Eventos
  - Tab 2: Crear Evento (modal)
  - Tab 3: EventiBot (modal animado)
  - Tab 4: Perfil de usuario
- [x] **Degradados modernos** en toda la app
- [x] **Animaciones del logo** en EventiBot
- [x] **Modales nativos** para date/time selection

### 💬 Sistema de Asistencias
- [x] Votar "Asistir", "No Asistir", "Tal vez"
- [x] Visualización de respuestas en EventDetailView
- [x] Datos mock de asistencias realistas

### 📊 Datos Mock (2025)
- [x] 6 eventos con fechas actualizadas
- [x] 9 usuarios con credenciales funcionales  
- [x] 15 respuestas de asistencia
- [x] Datos JSON bien estructurados

## 📁 Estructura del Proyecto

```
EventifyAI/
├── Eventify/Eventify/EventifyAI/
│   ├── Configuration/App/
│   │   └── EventifyAIApp.swift       # App principal SwiftUI
│   ├── Domain/
│   │   ├── Entities/                 # Models de negocio
│   │   └── Protocols/                # Contratos para repositories
│   ├── Data/
│   │   ├── Repository/               # Implementaciones con mock data
│   │   └── Local/KeyChain/           # Almacenamiento seguro
│   ├── Presentation/
│   │   ├── Views/
│   │   │   ├── Login/                # Pantallas de autenticación
│   │   │   ├── Principal/
│   │   │   │   ├── HomeView.swift    # TabView principal
│   │   │   │   └── Events/
│   │   │   │       ├── CreateEventView.swift  # ✅ Con date/time pickers
│   │   │   │       ├── EventDetailView.swift  # ✅ Carga automática
│   │   │   │       └── EventsRowView.swift
│   │   │   └── Tools/                # Componentes reutilizables
│   │   └── ViewModels/               # MVVM pattern
│   │       ├── CreateEventViewModel.swift  # ✅ Con date/time sync
│   │       └── EventDetailViewModel.swift
│   ├── UseCases/                     # Lógica de negocio
│   ├── Resources/                    # Mock data JSON
│   │   ├── events.json              # ✅ Fechas 2025
│   │   ├── users.json               # ✅ Datos actualizados
│   │   └── attendances.json         # ✅ Respuestas mock
│   └── Tools/                       # Utilidades y constantes
└── EventifyBackend/                 # Proyecto Vapor Swift (futuro)
```

## 🎯 Decisiones Técnicas

### ¿Por qué Clean Architecture + MVVM?
- **Separación clara**: Views, ViewModels, UseCases, Repositories
- **Testabilidad**: Cada capa se puede testear independientemente
- **Mantenibilidad**: Cambios en una capa no afectan otras
- **Escalabilidad**: Fácil agregar nuevas funcionalidades

### ¿Por qué SwiftUI + @Published?
- **Declarativo**: UI más predecible y fácil de mantener
- **Reactive**: Binding automático entre ViewModels y Views
- **Nativo**: Performance optimizada y APIs modernas
- **Date/Time Pickers**: Modales nativos con excelente UX

### ¿Por qué Mock Data en JSON?
- **Desarrollo rápido**: No requiere backend para testing
- **Datos realistas**: Eventos, usuarios y asistencias consistentes
- **Fácil modificación**: JSON files editables
- **Transición suave**: Fácil cambio a API real más adelante

## 🚀 Próximos Pasos

### Prioridad Alta
- [ ] **EventiBot IA**: Chat inteligente para crear eventos por voz/texto
- [ ] **API Integration**: Conectar con backend real (Vapor Swift incluido)
- [ ] **Notificaciones Push**: Recordatorios de eventos próximos

### Prioridad Media  
- [ ] **Búsqueda y Filtros**: Por fecha, ubicación, categorías
- [ ] **Compartir Eventos**: Invitaciones por WhatsApp/Email/Calendar
- [ ] **Modo Offline**: Sincronización cuando hay conexión

### Prioridad Baja
- [ ] **Autenticación Biométrica**: Face ID / Touch ID
- [ ] **Geolocalización**: Mapas integrados para ubicaciones  
- [ ] **Temas Personalizables**: Modo oscuro y colores custom
- [ ] **Analytics**: Métricas de uso y engagement

## 🎯 Demo Screens

### 🔐 Login Screen
- Autenticación con email/password
- Validación en tiempo real
- Diseño moderno con degradados

### 🏠 Home - Lista de Eventos
- Vista de eventos próximos y pasados
- Navegación directa a detalles
- Botón de logout integrado

### ➕ Crear Evento
- **✅ Date/Time Pickers completamente funcionales**
- Formulario con validación en tiempo real
- Modal sheets nativos para selección temporal

### 📋 Detalle de Evento  
- **✅ Carga automática de datos del evento**
- Sistema de votación de asistencia funcional
- Vista completa con toda la información

### 🤖 EventiBot Modal
- Animación del logo con rotación continua
- Efectos de pulsación y opacidad
- Preparado para futura integración de IA

## 📝 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Contacto

**Javier Gómez** - Estudiante de Bootcamp iOS javiergomezdev@gmail.com
**Santiago Soto** - Estudiante de Bootcamp iOS santiagocotovila@outlook.com
**Manuel Liebana** - Estudiante de Bootcamp iOS manololiebana@gmail.com

Proyecto EventifyAI - Gestión de Eventos con SwiftUI

Enlace del Proyecto: https://github.com/santicotovila/Eventify.git

---

**EventifyAI** - *Gestiona tus eventos con inteligencia* 🎯  
*Desarrollado con Clean Architecture + MVVM + SwiftUI*  
*Date/Time Pickers ✅ | EventDetailView ✅ | Mock Data 2025 ✅*
