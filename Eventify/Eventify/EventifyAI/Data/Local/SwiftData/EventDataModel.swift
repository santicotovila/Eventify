import Foundation
import SwiftData

// SwiftData model para persistencia local de eventos
// Actúa como caché local manteniendo la arquitectura Clean
@Model
final class EventDataModel {
    
    // MARK: - Properties
    
    @Attribute(.unique) var id: String
    var title: String
    var eventDescription: String  // No usar 'description' - es keyword reservado
    var date: Date
    var location: String
    var organizerId: String
    var organizerName: String
    var isAllDay: Bool
    var tags: [String]
    var maxAttendees: Int?
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Initializers
    
    // Constructor desde Domain Model (EventModel)
    init(from eventModel: EventModel) {
        self.id = eventModel.id
        self.title = eventModel.title
        self.eventDescription = eventModel.description
        self.date = eventModel.date
        self.location = eventModel.location
        self.organizerId = eventModel.organizerId
        self.organizerName = eventModel.organizerName
        self.isAllDay = eventModel.isAllDay
        self.tags = eventModel.tags
        self.maxAttendees = eventModel.maxAttendees
        self.createdAt = eventModel.createdAt
        self.updatedAt = eventModel.updatedAt
    }
    
    // Constructor directo (requerido por SwiftData)
    init(
        id: String,
        title: String,
        eventDescription: String,
        date: Date,
        location: String,
        organizerId: String,
        organizerName: String,
        isAllDay: Bool = false,
        tags: [String] = [],
        maxAttendees: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.date = date
        self.location = location
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.isAllDay = isAllDay
        self.tags = tags
        self.maxAttendees = maxAttendees
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Domain Mapping

extension EventDataModel {
    
    // Convierte SwiftData model a Domain model (EventModel)
    func toDomainModel() -> EventModel {
        return EventModel(
            id: id,
            title: title,
            description: eventDescription,
            date: date,
            location: location,
            organizerId: organizerId,
            organizerName: organizerName,
            isAllDay: isAllDay,
            tags: tags,
            maxAttendees: maxAttendees,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // Actualiza propiedades desde Domain model
    func updateFromDomain(_ eventModel: EventModel) {
        self.title = eventModel.title
        self.eventDescription = eventModel.description
        self.date = eventModel.date
        self.location = eventModel.location
        self.organizerId = eventModel.organizerId
        self.organizerName = eventModel.organizerName
        self.isAllDay = eventModel.isAllDay
        self.tags = eventModel.tags
        self.maxAttendees = eventModel.maxAttendees
        self.updatedAt = Date()
    }
}

// MARK: - Preview Data

extension EventDataModel {
    
    // Datos para SwiftUI Previews
    static let preview = EventDataModel(
        id: "preview-event-1",
        title: "Evento de Preview",
        eventDescription: "Descripción del evento de preview",
        date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
        location: "Ubicación Preview",
        organizerId: "preview-user",
        organizerName: "Usuario Preview",
        tags: ["preview", "swiftdata"]
    )
}
