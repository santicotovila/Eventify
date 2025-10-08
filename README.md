# Eventi — iOS App (SwiftUI, MVVM, Clean Architecture)

A native app to discover, create, and manage events, with secure authentication and attendance tracking.
---

## Table of Contents
- [Key Advantages](#key-advantages)
- [Requirements](#requirements)
- [How to Run the Project](#how-to-run-the-project)
- [Navigation Structure](#navigation-structure)
- [Authentication](#authentication)
- [Attendance System](#attendance-system)
- [Roadmap](#roadmap)
- [Architecture (iOS)](#architecture-ios)
- [Quality & Testing](#quality--testing)
- [Performance & Accessibility](#performance--accessibility)
- [Backend (Technical Overview)](#backend-technical-overview)
- [Security & Compliance](#security--compliance)
- [Contact](#contact)

---

## Key Advantages
- Clear separation of responsibilities.  
- Easier unit testing.  
- Simpler maintenance and scaling.  

---

## Requirements
- iOS 18 or later.  

---

## How to Run the Project
1. Clone the repository.  
2. Open the project in Xcode.  
3. Adjust the **Bundle Identifier** and signing if needed.  
4. Run on a simulator or a physical device.  
5. Configure backend variables if you want to connect to the real server. (A `.env.example` is included)

> By default, the app can run fully with *mock* data.

---

## Navigation Structure
- **Events**: General list of events.  
- **New Event**: Creation via a modal view with date and time pickers.  
- **EventiBot**: Assistant with suggestions *(view in progress)*.  
- **Profile**: User info and settings.

---

## Authentication
- Sign in with **email** and **password**.  
- Real-time field validation.  
- Credentials securely stored in **Keychain**.  
- Global session state managed by `AppStateViewModel`.

---

## Attendance System
Each user can set their status for an event:
- *Going*  
- *Not going*  
- *Maybe*

The event detail screen shows the live count for each status.

---

## Roadmap
- [ ] Full **EventiBot** integration with AI (text and voice).  
- [ ] Push notifications for reminders.  
- [ ] Share events via WhatsApp, email, or calendar.  
- [ ] Biometric authentication (Face ID / Touch ID).  
- [ ] Geolocation and interactive maps.  
- [ ] Personal app customization.

---

## Architecture (iOS)
- **MVVM** with **SwiftUI**.  
- **Layers**:
  - **Presentation**: SwiftUI views and ViewModels (state and bindings).  
  - **Domain**: Use cases, entities, and protocols.  
  - **Data**: Repositories, data sources (remote/local), *mappers*, and *DTOs*.  
- **Principles**: dependency injection, low coupling, testability.
  
## Reactive Frameworks & Patterns
- **State management (SwiftUI):** `@State`, `@Binding`, `@ObservedObject`, `@Environment` for unidirectional data flow and reactive views.
  
## Quality & Testing
- **Unit Tests** for use cases and *ViewModels*.  
- **Mocks/Stubs** for repositories and data sources.  

## Performance & Accessibility

---

## Backend (Technical Overview)

**Goal:**  
Build a solid, secure, and scalable base to manage users, events, and interests within the app.

### Technology
- **Framework:** Vapor  
- **Tools:** Postman for endpoint testing  
- **Databases:** SQLite in local environment and PostgreSQL in production  

### Project Structure
Code is organized into well-defined modules:
- `Models`
- `Controllers`
- `DTOs`
- `Migrations`
- `Middleware`
- `JWT`
- `Jobs`
- `Tools/Constants`

### Core Models
- **User:** normalized emails and passwords encrypted with **BCrypt**.  
- **Interest / UserInterest:** optimized many-to-many relationship to manage user interests.  
- **Event:** includes name, date, category, location, and coordinates.  
- **EventAttendance:** defines the different attendance states for users per event.

### Authentication
Implemented via **JWT tokens** (access and refresh), with protected routes according to role and access level.

### Security
- Private keys are kept out of the repository.  
- No credentials are included in the source code.  
- A `.env.example` is provided to test the server.

### Migrations
Include entity creation, pivot relationships, and an initial *seed* for testing and development.

---

## Security & Compliance
*(Reserved section for future policies and compliance details.)*

---

## Contact
- Javier Gómez — [javiergomezdev@gmail.com](mailto:javiergomezdev@gmail.com)  
- Santiago Coto — [santiagocotovila@outlook.com](mailto:santiagocotovila@outlook.com)  
- Manuel Liébana — [manololiebana@gmail.com](mailto:manololiebana@gmail.com)
