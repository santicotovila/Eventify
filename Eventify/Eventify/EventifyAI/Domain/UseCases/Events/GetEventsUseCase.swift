import Foundation

// Define qué cosas puede hacer para obtener eventos
protocol GetEventsUseCaseProtocol {
    func getUserEvents() async throws -> [Event]
    func getEventById(_ id: String) async throws -> Event?
    func getUpcomingEvents() async throws -> [Event]
}

// Esta clase se encarga de traer los eventos
// Los ordena y filtra como necesitemos
final class GetEventsUseCase: GetEventsUseCaseProtocol {
    
    // Cosas que necesita para funcionar
    private let eventRepository: EventRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    
    // Constructor
    init(eventRepository: EventRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.eventRepository = eventRepository
        self.authRepository = authRepository
    }
    
    // Métodos principales
    
    // Trae todos los eventos del usuario que está logueado
    func getUserEvents() async throws -> [Event] {
        guard let currentUser = authRepository.getCurrentUser() else {
            throw EventError.userNotAuthenticated
        }
        
        let events = try await eventRepository.getUserEvents(userId: currentUser.id)
        
        // Ordenarlos por fecha (los más próximos primero)
        return events.sorted { $0.dateTime < $1.dateTime }
    }
    
    // Busca un evento por su ID
    func getEventById(_ id: String) async throws -> Event? {
        return try await eventRepository.getEventById(id)
    }
    
    // Trae solo los eventos que aún no han pasado
    func getUpcomingEvents() async throws -> [Event] {
        let allEvents = try await getUserEvents()
        let now = Date()
        
        return allEvents.filter { $0.dateTime > now }
    }
}