import Foundation

protocol NetworkEventsProtocol {
    func getEvents(userId: String) async throws -> [EventModel]
    func getEventById(eventId: String) async throws -> EventModel?
    func createEvent(event: EventModel) async throws -> EventModel
    func updateEvent(eventId: String, event: EventModel) async throws -> EventModel
    func deleteEvent(eventId: String) async throws
}

final class NetworkEvents: NetworkEventsProtocol {
    
    // MARK: - Mock Data
    private var mockEvents: [EventModel] {
        let baseDate = Date()
        let date1 = Calendar.current.date(byAdding: .day, value: 3, to: baseDate) ?? baseDate
        let date2 = Calendar.current.date(byAdding: .day, value: 7, to: baseDate) ?? baseDate
        let date3 = Calendar.current.date(byAdding: .day, value: 10, to: baseDate) ?? baseDate
        
        return [
            EventModel(
                id: "event-1",
                title: "Reunión de Equipo",
                description: "Revisión semanal del proyecto EventifyAI",
                date: date1,
                location: "Sala de conferencias A",
                organizerId: "user-1",
                organizerName: "Ana García"
            ),
            EventModel(
                id: "event-2",
                title: "Workshop iOS",
                description: "Taller de desarrollo de aplicaciones iOS con SwiftUI",
                date: date2,
                location: "Laboratorio 3",
                organizerId: "user-2",
                organizerName: "Carlos Ruiz"
            ),
            EventModel(
                id: "event-3",
                title: "Almuerzo de Networking",
                description: "Evento de networking para desarrolladores",
                date: date3,
                location: "Restaurante Central",
                organizerId: "user-3",
                organizerName: "María López"
            )
        ]
    }
    
    // MARK: - Network Methods
    
    func getEvents(userId: String) async throws -> [EventModel] {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        
        // Simular posible error de red (10% de probabilidad)
        if Int.random(in: 1...10) == 1 {
            throw NetworkError.internalServerError
        }
        
        // Filtrar eventos por usuario (mock)
        return mockEvents.filter { event in
            event.organizerId == userId || userId == "user-1" // user-1 ve todos los eventos
        }
    }
    
    func getEventById(eventId: String) async throws -> EventModel? {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
        
        return mockEvents.first(where: { $0.id == eventId })
    }
    
    func createEvent(event: EventModel) async throws -> EventModel {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        
        // Simular posible error de validación
        if event.title.isEmpty {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        // Crear evento con nuevo ID
        let newEvent = EventModel(
            id: "event-\(UUID().uuidString)",
            title: event.title,
            description: event.description,
            date: event.date,
            location: event.location,
            organizerId: event.organizerId,
            organizerName: event.organizerName
        )
        
        return newEvent
    }
    
    func updateEvent(eventId: String, event: EventModel) async throws -> EventModel {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        
        // Verificar que el evento existe
        guard mockEvents.contains(where: { $0.id == eventId }) else {
            throw NetworkError.notFound
        }
        
        let updatedEvent = EventModel(
            id: eventId,
            title: event.title,
            description: event.description,
            date: event.date,
            location: event.location,
            organizerId: event.organizerId,
            organizerName: event.organizerName
        )
        
        return updatedEvent
    }
    
    func deleteEvent(eventId: String) async throws {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 segundos
        
        // Verificar que el evento existe
        guard mockEvents.contains(where: { $0.id == eventId }) else {
            throw NetworkError.notFound
        }
        
        // Simular eliminación exitosa
    }
}