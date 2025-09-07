import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Protocolo que define las operaciones remotas con Firebase
protocol FirebaseDataSourceProtocol {
    // Auth operations
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() -> User?
    
    // Event operations
    func createEvent(_ event: Event) async throws -> Event
    func getUserEvents(userId: String) async throws -> [Event]
    func getEventById(_ id: String) async throws -> Event?
    func saveAttendance(_ attendance: Attendance) async throws -> Attendance
    func getAttendances(for eventId: String) async throws -> [Attendance]
}

/// Implementación del data source remoto usando Firebase
final class FirebaseDataSource: FirebaseDataSourceProtocol {
    
    // MARK: - Properties
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    // MARK: - Collections
    private var eventsCollection: CollectionReference {
        firestore.collection("events")
    }
    
    private var attendancesCollection: CollectionReference {
        firestore.collection("attendances")
    }
    
    // MARK: - Auth Implementation
    
    /// Inicia sesión con Firebase Auth
    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return User(
                id: result.user.uid,
                email: result.user.email ?? email
            )
        } catch {
            // Mapear errores de Firebase a errores de dominio
            throw mapAuthError(error)
        }
    }
    
    /// Registra un nuevo usuario con Firebase Auth
    func signUp(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return User(
                id: result.user.uid,
                email: result.user.email ?? email
            )
        } catch {
            throw mapAuthError(error)
        }
    }
    
    /// Cierra sesión en Firebase Auth
    func signOut() async throws {
        do {
            try auth.signOut()
        } catch {
            throw mapAuthError(error)
        }
    }
    
    /// Obtiene el usuario actualmente autenticado
    func getCurrentUser() -> User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? ""
        )
    }
    
    // MARK: - Event Implementation
    
    /// Crea un evento en Firestore
    func createEvent(_ event: Event) async throws -> Event {
        do {
            let eventData = try event.toDictionary()
            try await eventsCollection.document(event.id).setData(eventData)
            return event
        } catch {
            throw NetworkError.serverError(0)
        }
    }
    
    /// Obtiene eventos del usuario desde Firestore
    func getUserEvents(userId: String) async throws -> [Event] {
        do {
            // Obtener eventos donde el usuario es creador
            let createdEventsQuery = eventsCollection.whereField("creatorId", isEqualTo: userId)
            let createdSnapshot = try await createdEventsQuery.getDocuments()
            let createdEvents = try createdSnapshot.documents.compactMap { try Event.fromDictionary($0.data()) }
            
            // TODO: En el futuro, también buscar eventos donde el usuario fue invitado
            // Por ahora solo devolvemos los eventos creados por el usuario
            
            return createdEvents
        } catch {
            throw NetworkError.serverError(0)
        }
    }
    
    /// Busca un evento por ID en Firestore
    func getEventById(_ id: String) async throws -> Event? {
        do {
            let document = try await eventsCollection.document(id).getDocument()
            guard let data = document.data() else { return nil }
            return try Event.fromDictionary(data)
        } catch {
            throw NetworkError.serverError(0)
        }
    }
    
    // MARK: - Attendance Implementation
    
    /// Guarda una asistencia en Firestore
    func saveAttendance(_ attendance: Attendance) async throws -> Attendance {
        do {
            let attendanceData = try attendance.toDictionary()
            try await attendancesCollection.document(attendance.id).setData(attendanceData)
            return attendance
        } catch {
            throw NetworkError.serverError(0)
        }
    }
    
    /// Obtiene asistencias de un evento desde Firestore
    func getAttendances(for eventId: String) async throws -> [Attendance] {
        do {
            let query = attendancesCollection.whereField("eventId", isEqualTo: eventId)
            let snapshot = try await query.getDocuments()
            return try snapshot.documents.compactMap { try Attendance.fromDictionary($0.data()) }
        } catch {
            throw NetworkError.serverError(0)
        }
    }
    
    // MARK: - Private Methods
    
    /// Mapea errores de Firebase Auth a errores de dominio
    private func mapAuthError(_ error: Error) -> AuthError {
        guard let authError = error as NSError? else {
            return .unknownAuthError
        }
        
        switch authError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.userDisabled.rawValue:
            return .userDisabled
        case AuthErrorCode.tooManyRequests.rawValue:
            return .tooManyRequests
        default:
            return .unknownAuthError
        }
    }
}