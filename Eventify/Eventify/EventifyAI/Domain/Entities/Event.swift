import Foundation

// Esta clase representa un evento que alguien creó
// Tiene toda la info del evento como título, fecha, lugar, etc.
struct Event: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let creatorId: String
    let creatorEmail: String
    let dateTime: Date
    let location: String
    let createdAt: Date
    let updatedAt: Date
    
    // Estas funciones nos ayudan a mostrar la info de manera bonita
    var isUpcoming: Bool {
        dateTime > Date()
    }
    
    var formattedDate: String {
        DateFormatter.eventFormatter.string(from: dateTime)
    }
    
    var formattedTime: String {
        DateFormatter.timeFormatter.string(from: dateTime)
    }
    
    // Esto crea un evento nuevo con toda su info
    init(title: String, description: String, creatorId: String, creatorEmail: String, dateTime: Date, location: String) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.creatorId = creatorId
        self.creatorEmail = creatorEmail
        self.dateTime = dateTime
        self.location = location
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Este se usa cuando sacamos un evento de la base de datos
    init(id: String, title: String, description: String, creatorId: String, creatorEmail: String, dateTime: Date, location: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.creatorId = creatorId
        self.creatorEmail = creatorEmail
        self.dateTime = dateTime
        self.location = location
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}