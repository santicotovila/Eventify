import Foundation

// Protocolo que define las operaciones de negocio para los eventos.
protocol EventsUseCaseProtocol {
    func getEvents(for userId: String) async throws -> [EventModel]
    func getEventById(_ id: String) async throws -> EventModel?
    func createEvent(_ event: EventModel) async throws -> EventModel
    func updateEvent(_ event: EventModel) async throws -> EventModel
    func deleteEvent(eventId: String) async throws
    func syncEvents() async throws
}

// Implementación con la lógica de negocio para la gestión de eventos.
final class EventsUseCase: EventsUseCaseProtocol {
    
    // MARK: - Dependencias
    private let repository: EventsRepositoryProtocol
    private let loginRepository: LoginRepositoryProtocol
    
    init(repository: EventsRepositoryProtocol, loginRepository: LoginRepositoryProtocol) {
        self.repository = repository
        self.loginRepository = loginRepository
    }
    
    // MARK: - Funciones Públicas
    
    func getEvents(for userId: String) async throws -> [EventModel] {
        do {
            // Pide los eventos al repositorio.
            let events = try await repository.getEvents(for: userId)
            // Regla de negocio: devolver los eventos siempre ordenados por fecha.
            let sortedEvents = events.sorted { $0.date < $1.date }
            return sortedEvents
        } catch {
            throw EventsUseCaseError.fetchFailed(error)
        }
    }
    
    func getEventById(_ id: String) async throws -> EventModel? {
        do {
            return try await repository.getEventById(id)
        } catch {
            throw EventsUseCaseError.fetchFailed(error)
        }
    }
    
    func createEvent(_ event: EventModel) async throws -> EventModel {
        guard let currentUser = loginRepository.getCurrentUser() else {
            throw EventsUseCaseError.userNotAuthenticated
        }
        
        // Regla de negocio: validar los datos antes de crear.
        try validateEventData(event)
        
        // Regla de negocio: asegurar que el organizador es el usuario logueado.
        let newEvent = EventModel(
            title: event.title,
            description: event.description,
            date: event.date,
            location: event.location,
            organizerId: currentUser.id,
            organizerName: currentUser.displayName ?? "Usuario",
            isAllDay: event.isAllDay,
            tags: event.tags,
            maxAttendees: event.maxAttendees
        )
        
        do {
            return try await repository.createEvent(newEvent)
        } catch {
            throw EventsUseCaseError.createFailed(error)
        }
    }
    
    func updateEvent(_ event: EventModel) async throws -> EventModel {
        guard let currentUser = loginRepository.getCurrentUser() else {
            throw EventsUseCaseError.userNotAuthenticated
        }
        
        // Regla de negocio: solo el organizador puede editar el evento.
        guard event.organizerId == currentUser.id else {
            throw EventsUseCaseError.notAuthorized
        }
        
        try validateEventData(event)
        
        do {
            return try await repository.updateEvent(event)
        } catch {
            throw EventsUseCaseError.updateFailed(error)
        }
    }
    
    func deleteEvent(eventId: String) async throws {
        guard let currentUser = loginRepository.getCurrentUser() else {
            throw EventsUseCaseError.userNotAuthenticated
        }
        
        guard let event = try await repository.getEventById(eventId) else {
            throw EventsUseCaseError.eventNotFound
        }
        
        guard event.organizerId == currentUser.id else {
            throw EventsUseCaseError.notAuthorized
        }
        
        do {
            try await repository.deleteEvent(eventId: eventId)
        } catch {
            throw EventsUseCaseError.deleteFailed(error)
        }
    }
    
    func syncEvents() async throws {
        guard loginRepository.getCurrentUser() != nil else {
            throw EventsUseCaseError.userNotAuthenticated
        }
        
        do {
            // Sync functionality would be implemented here in a real app
            // For now, this is a placeholder
        } catch {
            throw EventsUseCaseError.syncFailed(error)
        }
    }
    
    // MARK: - Funciones de Conveniencia
    
    func getUpcomingEvents(for userId: String) async throws -> [EventModel] {
        let events = try await getEvents(for: userId)
        let now = Date()
        return events.filter { $0.date > now }
    }
    
    func getPastEvents(for userId: String) async throws -> [EventModel] {
        let events = try await getEvents(for: userId)
        let now = Date()
        return events.filter { $0.date <= now }
    }
    
    func searchEvents(query: String, for userId: String) async throws -> [EventModel] {
        let events = try await getEvents(for: userId)
        if query.isEmpty { return events }
        
        let lowercaseQuery = query.lowercased()
        return events.filter {
            $0.title.lowercased().contains(lowercaseQuery) ||
            $0.description.lowercased().contains(lowercaseQuery) ||
            $0.location.lowercased().contains(lowercaseQuery)
        }
    }
    
    // MARK: - Validación Privada
    
    private func validateEventData(_ event: EventModel) throws {
        guard !event.title.isEmpty else { throw EventsUseCaseError.invalidTitle }
        guard event.title.count <= ConstantsApp.Validation.maxEventTitleLength else { throw EventsUseCaseError.titleTooLong }
        guard event.description.count <= ConstantsApp.Validation.maxEventDescriptionLength else { throw EventsUseCaseError.descriptionTooLong }
        guard event.date > Date() else { throw EventsUseCaseError.invalidDate }
        guard !event.location.isEmpty else { throw EventsUseCaseError.invalidLocation }
        if let maxAttendees = event.maxAttendees, maxAttendees <= 0 {
            throw EventsUseCaseError.invalidMaxAttendees
        }
    }
}

// Errores específicos para la gestión de eventos.
enum EventsUseCaseError: Error, LocalizedError {
    case userNotAuthenticated
    case eventNotFound
    case notAuthorized
    case invalidTitle
    case titleTooLong
    case descriptionTooLong
    case invalidDate
    case invalidLocation
    case invalidMaxAttendees
    case fetchFailed(Error)
    case createFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    case syncFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated: return "Debes iniciar sesión para realizar esta acción"
        case .eventNotFound: return "Evento no encontrado"
        case .notAuthorized: return "No tienes permisos para modificar este evento"
        case .invalidTitle: return "El título del evento es requerido"
        case .titleTooLong: return "El título no puede exceder \(ConstantsApp.Validation.maxEventTitleLength) caracteres"
        case .descriptionTooLong: return "La descripción no puede exceder \(ConstantsApp.Validation.maxEventDescriptionLength) caracteres"
        case .invalidDate: return "La fecha del evento debe ser futura"
        case .invalidLocation: return "La ubicación del evento es requerida"
        case .invalidMaxAttendees: return "El número máximo de asistentes debe ser mayor a 0"
        case .fetchFailed(let error): return "Error al obtener eventos: \(error.localizedDescription)"
        case .createFailed(let error): return "Error al crear evento: \(error.localizedDescription)"
        case .updateFailed(let error): return "Error al actualizar evento: \(error.localizedDescription)"
        case .deleteFailed(let error): return "Error al eliminar evento: \(error.localizedDescription)"
        case .syncFailed(let error): return "Error al sincronizar eventos: \(error.localizedDescription)"
        }
    }
}