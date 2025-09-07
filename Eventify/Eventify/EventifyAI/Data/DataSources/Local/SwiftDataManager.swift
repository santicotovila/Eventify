import Foundation
import SwiftData

/// Manager singleton para configurar SwiftData en la aplicación
final class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    /// Container principal de SwiftData para la aplicación
    let container: ModelContainer
    
    private init() {
        do {
            // Configurar el schema con nuestros modelos
            let schema = Schema([
                EventDataModel.self,
                AttendanceDataModel.self
            ])
            
            // Configurar el contenedor con opciones
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false // Persistir en disco
            )
            
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Error configurando SwiftData: \(error)")
        }
    }
    
    /// Crea un nuevo contexto para operaciones específicas
    @MainActor
    func createContext() -> ModelContext {
        return ModelContext(container)
    }
}

/// Modelo de SwiftData para eventos (caché local)
/// Utiliza @Model para integración automática con SwiftData
@Model
final class EventDataModel {
    @Attribute(.unique) var id: String
    var title: String
    var eventDescription: String // 'description' es palabra reservada
    var creatorId: String
    var creatorEmail: String
    var dateTime: Date
    var location: String
    var createdAt: Date
    var updatedAt: Date
    
    init(from event: Event) {
        self.id = event.id
        self.title = event.title
        self.eventDescription = event.description
        self.creatorId = event.creatorId
        self.creatorEmail = event.creatorEmail
        self.dateTime = event.dateTime
        self.location = event.location
        self.createdAt = event.createdAt
        self.updatedAt = event.updatedAt
    }
    
    /// Convierte el modelo de SwiftData a entidad de dominio
    func toEvent() -> Event {
        return Event(
            id: id,
            title: title,
            description: eventDescription,
            creatorId: creatorId,
            creatorEmail: creatorEmail,
            dateTime: dateTime,
            location: location,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

/// Modelo de SwiftData para asistencias (caché local)
@Model
final class AttendanceDataModel {
    @Attribute(.unique) var id: String
    var eventId: String
    var userId: String
    var userEmail: String
    var status: String // Guardamos el raw value del enum
    var respondedAt: Date
    
    init(from attendance: Attendance) {
        self.id = attendance.id
        self.eventId = attendance.eventId
        self.userId = attendance.userId
        self.userEmail = attendance.userEmail
        self.status = attendance.status.rawValue
        self.respondedAt = attendance.respondedAt
    }
    
    /// Convierte el modelo de SwiftData a entidad de dominio
    func toAttendance() -> Attendance? {
        guard let attendanceStatus = AttendanceStatus(rawValue: status) else {
            return nil
        }
        
        return Attendance(
            id: id,
            eventId: eventId,
            userId: userId,
            userEmail: userEmail,
            status: attendanceStatus,
            respondedAt: respondedAt
        )
    }
}