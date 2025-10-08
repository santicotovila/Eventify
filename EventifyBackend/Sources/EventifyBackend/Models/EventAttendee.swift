

import Fluent
import Vapor


// Modelo que representa la asistencia de un usuario a un evento.
// Cada instancia es la relación usuario → evento, con su estado y fechas.
final class EventAttendee: Model, @unchecked Sendable {
    static let schema = ConstantsEventAttendees.schema
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: ConstantsEventAttendees.eventID)
    var event: Events
    
    @Parent(key: ConstantsEventAttendees.userID)
    var user: Users
    
    
    @Field(key: ConstantsEventAttendees.status)
    var status: String
    
    @Timestamp(key: ConstantsEventAttendees.joinedAt, on: .create)
    var joinedAt: Date?
    
    @Timestamp(key: ConstantsEventAttendees.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(eventID: UUID, userID: UUID, status: EventStatus) {
        self.$event.id = eventID
        self.$user.id = userID
        self.status = status.rawValue
    }
}
