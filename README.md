# Eventify — iOS App (SwiftUI, MVVM, Clean Architecture)

## ScreenShots
<img width="300" height="615" alt="Home" src="https://github.com/user-attachments/assets/99c4429c-cde1-4dd9-80f8-403ce24dee45" /><img width="300" height="615" alt="Register1" src="https://github.com/user-attachments/assets/9e64b237-9363-410b-80bf-a07ff6671cd8" /><img width="300" height="615" alt="Register2" src="https://github.com/user-attachments/assets/1456dfe5-3330-4e6a-aa18-b2a3a5794183" /><img width="300" height="615" alt="Events" src="https://github.com/user-attachments/assets/f37bfe88-8066-42c3-97dc-a9eb146b099e" /><img width="300" height="615" alt="CreateEvent" src="https://github.com/user-attachments/assets/db50e116-5315-4ab1-b692-669411b53bf8" /><img width="300" height="615" alt="Event Eventify" src="https://github.com/user-attachments/assets/c1b4c4f0-e08c-49cb-bdc7-7b513c81e20e" /><img width="300" height="615" alt="Friends" src="https://github.com/user-attachments/assets/3601942b-1508-456b-b3c2-ef64acb84c6c" /><img width="300" height="615" alt="Friends2" src="https://github.com/user-attachments/assets/fa580d51-de0e-486a-88f2-1d93a725aa75" /><img width="300" height="615" alt="seeEvent" src="https://github.com/user-attachments/assets/5a1e7534-4d27-4282-8917-146d84e25e47" /><img width="300" height="615" alt="IA" src="https://github.com/user-attachments/assets/add1fc86-8a89-40f1-8daf-b7cda6a13f69" /><img width="300" height="615" alt="Profile" src="https://github.com/user-attachments/assets/2648f9d9-aed4-4180-9c68-0697ec500ea5" />

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
