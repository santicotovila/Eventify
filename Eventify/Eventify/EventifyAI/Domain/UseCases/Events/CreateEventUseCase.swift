import Foundation

// Define qué cosas puede hacer la creación de eventos
protocol CreateEventUseCaseProtocol {
    func execute(title: String, description: String, dateTime: Date, location: String) async throws -> Event
}

// Esta clase se encarga de crear eventos nuevos
// Revisa que todo esté bien antes de guardar
final class CreateEventUseCase: CreateEventUseCaseProtocol {
    
    // Cosas que necesita para funcionar
    private let eventRepository: EventRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    
    // Constructor
    init(eventRepository: EventRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.eventRepository = eventRepository
        self.authRepository = authRepository
    }
    
    // Método principal
    
    // Crea un evento nuevo con toda la info que le pasemos
    func execute(title: String, description: String, dateTime: Date, location: String) async throws -> Event {
        
        // Revisar que haya alguien logueado
        guard let currentUser = authRepository.getCurrentUser() else {
            throw EventError.userNotAuthenticated
        }
        
        // Revisar que los datos estén bien
        try validateEventData(title: title, description: description, dateTime: dateTime, location: location)
        
        // Crear el evento con toda la info
        let event = Event(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            creatorId: currentUser.id,
            creatorEmail: currentUser.email,
            dateTime: dateTime,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // Guardarlo en la base de datos
        return try await eventRepository.createEvent(event)
    }
    
    // Métodos internos
    
    // Revisa que todos los datos del evento estén correctos
    private func validateEventData(title: String, description: String, dateTime: Date, location: String) throws {
        
        // Revisar el título
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw EventError.emptyTitle
        }
        guard trimmedTitle.count >= 3 else {
            throw EventError.titleTooShort
        }
        
        // Revisar la descripción
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDescription.isEmpty else {
            throw EventError.emptyDescription
        }
        
        // Revisar la ubicación
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLocation.isEmpty else {
            throw EventError.emptyLocation
        }
        
        // Revisar que la fecha sea en el futuro (al menos 5 minutos)
        let minimumDate = Date().addingTimeInterval(5 * 60) // 5 minutos en el futuro
        guard dateTime > minimumDate else {
            throw EventError.invalidDateTime
        }
    }
}