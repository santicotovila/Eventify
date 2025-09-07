import Foundation

// Estas son las opciones para responder si vas a un evento
// Solo puedes elegir sí, no, o tal vez
enum AttendanceStatus: String, CaseIterable, Codable {
    case yes = "yes"
    case no = "no"
    case maybe = "maybe"
    
    // Texto que se ve en la app
    var displayText: String {
        switch self {
        case .yes:
            return "Sí"
        case .no:
            return "No"
        case .maybe:
            return "Tal vez"
        }
    }
    
    // Color que le ponemos a cada opción
    var colorName: String {
        switch self {
        case .yes:
            return "green"
        case .no:
            return "red"
        case .maybe:
            return "orange"
        }
    }
}

// Esto guarda la respuesta de una persona a un evento
// Así sabemos quién dijo que sí, no, o tal vez
struct Attendance: Identifiable, Codable, Equatable {
    let id: String
    let eventId: String
    let userId: String
    let userEmail: String
    let status: AttendanceStatus
    let respondedAt: Date
    
    // Esto crea una respuesta nueva cuando alguien vota
    init(eventId: String, userId: String, userEmail: String, status: AttendanceStatus) {
        self.id = UUID().uuidString
        self.eventId = eventId
        self.userId = userId
        self.userEmail = userEmail
        self.status = status
        self.respondedAt = Date()
    }
    
    // Este se usa cuando sacamos la respuesta de la base de datos
    init(id: String, eventId: String, userId: String, userEmail: String, status: AttendanceStatus, respondedAt: Date) {
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.userEmail = userEmail
        self.status = status
        self.respondedAt = respondedAt
    }
}