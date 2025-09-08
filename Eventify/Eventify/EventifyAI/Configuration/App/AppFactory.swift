import Foundation

// MARK: - App Factory
/// Factory class para crear todas las dependencias de la aplicación
/// Implementa el patrón Dependency Injection Container
final class AppFactory {
    
    // MARK: - Singleton
    static let shared = AppFactory()
    
    // MARK: - Private Properties
    private var loginRepository: LoginRepositoryProtocol?
    private var eventsRepository: EventsRepositoryProtocol?
    private var attendanceRepository: AttendanceRepositoryProtocol?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Repository Factory Methods
    
    func makeLoginRepository() -> LoginRepositoryProtocol {
        if let repository = loginRepository {
            return repository
        }
        
        let repository = DefaultLoginRepository(
            networkLogin: NetworkLogin(),
            keychain: .shared
        )
        self.loginRepository = repository
        return repository
    }
    
    func makeEventsRepository() -> EventsRepositoryProtocol {
        if let repository = eventsRepository {
            return repository
        }
        
        let repository = DefaultEventsRepository(
            networkEvents: NetworkEvents(),
            keychain: .shared
        )
        self.eventsRepository = repository
        return repository
    }
    
    func makeAttendanceRepository() -> AttendanceRepositoryProtocol {
        if let repository = attendanceRepository {
            return repository
        }
        
        let repository = DefaultAttendanceRepository(
            networkAttendance: NetworkAttendance(),
            keychain: .shared
        )
        self.attendanceRepository = repository
        return repository
    }
    
    // MARK: - UseCase Factory Methods
    
    func makeLoginUseCase() -> LoginUseCaseProtocol {
        let repository = makeLoginRepository()
        return LoginUseCase(loginRepository: repository)
    }
    
    func makeEventsUseCase() -> EventsUseCaseProtocol {
        let repository = makeEventsRepository()
        let loginRepository = makeLoginRepository()
        return EventsUseCase(repository: repository, loginRepository: loginRepository)
    }
    
    func makeAttendanceUseCase() -> AttendanceUseCaseProtocol {
        let attendanceRepository = makeAttendanceRepository()
        let loginRepository = makeLoginRepository()
        let eventsRepository = makeEventsRepository()
        return AttendanceUseCase(
            attendanceRepository: attendanceRepository,
            loginRepository: loginRepository,
            eventsRepository: eventsRepository
        )
    }
}

