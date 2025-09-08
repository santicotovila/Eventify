import Foundation

// Estas son las opciones para responder si vas a un evento
// Solo puedes elegir sí, no, o tal vez
enum AttendanceStatus: String, CaseIterable, Codable {
    case going = "going"
    case notGoing = "notGoing"
    case maybe = "maybe"
    
    // Texto que se ve en la app
    var displayText: String {
        switch self {
        case .going:
            return "Asistiré"
        case .notGoing:
            return "No asistiré"
        case .maybe:
            return "Tal vez"
        }
    }
    
    // Color que le ponemos a cada opción
    var colorName: String {
        switch self {
        case .going:
            return "green"
        case .notGoing:
            return "red"
        case .maybe:
            return "orange"
        }
    }
}

// Esto guarda la respuesta de una persona a un evento
// Así sabemos quién dijo que sí, no, o tal vez
struct AttendanceModel: Identifiable, Codable, Equatable {
    var id: String
    let userId: String
    let eventId: String
    var status: AttendanceStatus
    let userName: String
    let userEmail: String
    let createdAt: Date
    
    // Esto crea una respuesta nueva cuando alguien vota
    init(userId: String, eventId: String, status: AttendanceStatus, userName: String, userEmail: String = "") {
        self.id = UUID().uuidString
        self.userId = userId
        self.eventId = eventId
        self.status = status
        self.userName = userName
        self.userEmail = userEmail
        self.createdAt = Date()
    }
    
    // Constructor simplificado para UseCases
    init(userId: String, eventId: String, status: AttendanceStatus, userName: String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.eventId = eventId
        self.status = status
        self.userName = userName
        self.userEmail = ""
        self.createdAt = Date()
    }
    
    // Este se usa cuando sacamos la respuesta de la base de datos o red
    init(id: String, userId: String, eventId: String, status: AttendanceStatus, userName: String, userEmail: String, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.eventId = eventId
        self.status = status
        self.userName = userName
        self.userEmail = userEmail
        self.createdAt = createdAt
    }
}