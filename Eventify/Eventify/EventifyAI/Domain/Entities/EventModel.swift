import Foundation

// Esta clase representa un evento que alguien creó
// Tiene toda la info del evento como título, fecha, lugar, etc.
struct EventModel: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let location: String
    let organizerId: String
    let organizerName: String
    let isAllDay: Bool
    let tags: [String]
    let maxAttendees: Int?
    let createdAt: Date
    let updatedAt: Date
    
    // Estas funciones nos ayudan a mostrar la info de manera bonita
    var isUpcoming: Bool {
        date > Date()
    }
    
    var formattedDate: String {
        DateFormatter.eventFormatter.string(from: date)
    }
    
    var formattedTime: String {
        DateFormatter.timeFormatter.string(from: date)
    }
    
    // Esto crea un evento nuevo con toda su info
    init(id: String = UUID().uuidString, title: String, description: String, date: Date, location: String, organizerId: String, organizerName: String, isAllDay: Bool = false, tags: [String] = [], maxAttendees: Int? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.location = location
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.isAllDay = isAllDay
        self.tags = tags
        self.maxAttendees = maxAttendees
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Este se usa cuando sacamos un evento de la base de datos
    init(id: String, title: String, description: String, date: Date, location: String, organizerId: String, organizerName: String, isAllDay: Bool = false, tags: [String] = [], maxAttendees: Int? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
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

// MARK: - Preview Extensions
extension EventModel {
    static let preview = EventModel(
        id: "preview-event-1",
        title: "Cena de Cumpleaños",
        description: "Celebremos el cumpleaños de Ana en su restaurante favorito",
        date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
        location: "Restaurante El Buen Gusto",
        organizerId: "user-preview",
        organizerName: "Ana García",
        tags: ["cumpleaños", "cena"]
    )
    
    static let previewPast = EventModel(
        id: "preview-event-2",
        title: "Reunión de Trabajo",
        description: "Reunión mensual del equipo de desarrollo",
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        location: "Oficina Central",
        organizerId: "user-preview-2",
        organizerName: "Carlos Rodríguez",
        tags: ["trabajo", "reunión"]
    )
}