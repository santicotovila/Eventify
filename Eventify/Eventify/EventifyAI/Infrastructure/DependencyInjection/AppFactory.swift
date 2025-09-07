import Foundation

// Esta clase crea todas las cosas que necesita la app
// Es como una fábrica que hace los objetos que necesitamos
class AppFactory {
    
    // Solo hay una instancia de esta clase en toda la app
    static let shared = AppFactory()
    private init() {}
    
    // Estas son las "herramientas" que usa la app
    private lazy var firebaseDataSource: FirebaseDataSourceProtocol = {
        FirebaseDataSource()
    }()
    
    private lazy var swiftDataDataSource: SwiftDataDataSourceProtocol = {
        do {
            return try SwiftDataDataSource()
        } catch {
            fatalError("No pude crear SwiftDataDataSource: \(error)")
        }
    }()
    
    private lazy var keychainManager: KeychainManagerProtocol = {
        KeychainManager()
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepository(firebaseDataSource: firebaseDataSource)
    }()
    
    private lazy var eventRepository: EventRepositoryProtocol = {
        EventRepository(
            firebaseDataSource: firebaseDataSource,
            localDataSource: swiftDataDataSource
        )
    }()
    
    // Métodos que crean las cosas que necesitan las pantallas
    
    // Crea lo que maneja login/registro
    func makeAuthUseCase() -> AuthUseCaseProtocol {
        return AuthUseCase(
            authRepository: authRepository,
            keychainManager: keychainManager
        )
    }
    
    // Crea lo que maneja crear eventos
    func makeCreateEventUseCase() -> CreateEventUseCaseProtocol {
        return CreateEventUseCase(
            eventRepository: eventRepository,
            authRepository: authRepository
        )
    }
    
    // Crea lo que maneja obtener eventos
    func makeGetEventsUseCase() -> GetEventsUseCaseProtocol {
        return GetEventsUseCase(
            eventRepository: eventRepository,
            authRepository: authRepository
        )
    }
    
    // Crea lo que maneja votar en eventos
    func makeVoteAttendanceUseCase() -> VoteAttendanceUseCaseProtocol {
        return VoteAttendanceUseCase(
            eventRepository: eventRepository,
            authRepository: authRepository
        )
    }
}