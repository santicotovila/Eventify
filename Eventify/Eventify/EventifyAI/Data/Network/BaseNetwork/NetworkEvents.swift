import Foundation

protocol NetworkEventsProtocol {
    func getEvents(userId: String) async throws -> [EventDTO]
    func getEventById(eventId: String) async throws -> EventDTO?
    func createEvent(event: CreateEventDTO) async throws -> EventDTO
    func updateEvent(eventId: String, event: EventDTO) async throws -> EventDTO
    func deleteEvent(eventId: String) async throws
}

final class NetworkEvents: NetworkEventsProtocol {
    
    // MARK: - Mock Data
    private let dateFormatter = ISO8601DateFormatter()
    
    private var mockEvents: [EventDTO] {
        let baseDate = Date()
        let date1 = Calendar.current.date(byAdding: .day, value: 3, to: baseDate) ?? baseDate
        let date2 = Calendar.current.date(byAdding: .day, value: 7, to: baseDate) ?? baseDate
        let date3 = Calendar.current.date(byAdding: .day, value: 10, to: baseDate) ?? baseDate
        let currentDateString = dateFormatter.string(from: baseDate)
        
        return [
            EventDTO(
                id: "event-1",
                title: "Reunión de Equipo",
                description: "Revisión semanal del proyecto EventifyAI",
                date: dateFormatter.string(from: date1),
                location: "Sala de conferencias A",
                organizerId: "user-1",
                organizerName: "Ana García",
                isAllDay: false,
                tags: ["trabajo", "equipo"],
                maxAttendees: 15,
                createdAt: currentDateString,
                updatedAt: currentDateString
            ),
            EventDTO(
                id: "event-2",
                title: "Workshop iOS",
                description: "Taller de desarrollo de aplicaciones iOS con SwiftUI",
                date: dateFormatter.string(from: date2),
                location: "Laboratorio 3",
                organizerId: "user-2",
                organizerName: "Carlos Ruiz",
                isAllDay: true,
                tags: ["educación", "tecnología", "iOS"],
                maxAttendees: 20,
                createdAt: currentDateString,
                updatedAt: currentDateString
            ),
            EventDTO(
                id: "event-3",
                title: "Almuerzo de Networking",
                description: "Evento de networking para desarrolladores",
                date: dateFormatter.string(from: date3),
                location: "Restaurante Central",
                organizerId: "user-3",
                organizerName: "María López",
                isAllDay: false,
                tags: ["networking", "profesional"],
                maxAttendees: 30,
                createdAt: currentDateString,
                updatedAt: currentDateString
            )
        ]
    }
    
    // MARK: - Network Methods
    
    func getEvents(userId: String) async throws -> [EventDTO] {
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
    
    func getEventById(eventId: String) async throws -> EventDTO? {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
        
        return mockEvents.first(where: { $0.id == eventId })
    }
    
    func createEvent(event: CreateEventDTO) async throws -> EventDTO {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        
        // Simular posible error de validación
        if event.title.isEmpty {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        // Crear evento con nuevo ID y fechas
        let currentDate = dateFormatter.string(from: Date())
        let newEvent = EventDTO(
            id: "event-\(UUID().uuidString)",
            title: event.title,
            description: event.description,
            date: event.date,
            location: event.location,
            organizerId: event.organizerId,
            organizerName: event.organizerName,
            isAllDay: event.isAllDay,
            tags: event.tags,
            maxAttendees: event.maxAttendees,
            createdAt: currentDate,
            updatedAt: currentDate
        )
        
        return newEvent
    }
    
    func updateEvent(eventId: String, event: EventDTO) async throws -> EventDTO {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        
        // Verificar que el evento existe
        guard mockEvents.contains(where: { $0.id == eventId }) else {
            throw NetworkError.notFound
        }
        
        let currentDate = dateFormatter.string(from: Date())
        let updatedEvent = EventDTO(
            id: eventId,
            title: event.title,
            description: event.description,
            date: event.date,
            location: event.location,
            organizerId: event.organizerId,
            organizerName: event.organizerName,
            isAllDay: event.isAllDay,
            tags: event.tags,
            maxAttendees: event.maxAttendees,
            createdAt: event.createdAt,
            updatedAt: currentDate
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

