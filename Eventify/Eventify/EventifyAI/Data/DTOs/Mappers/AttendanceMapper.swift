import Foundation

struct AttendanceMapper {
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static func toModel(from dto: AttendanceDTO) -> AttendanceModel? {
        guard let status = AttendanceStatus(rawValue: dto.status),
              let createdAt = dateFormatter.date(from: dto.createdAt) else {
            return nil
        }
        
        return AttendanceModel(
            id: dto.id,
            userId: dto.userId,
            eventId: dto.eventId,
            status: status,
            userName: dto.userName,
            userEmail: dto.userEmail,
            createdAt: createdAt
        )
    }
    
    static func toDTO(from model: AttendanceModel) -> AttendanceDTO {
        return AttendanceDTO(
            id: model.id,
            userId: model.userId,
            eventId: model.eventId,
            status: model.status.rawValue,
            userName: model.userName,
            userEmail: model.userEmail,
            createdAt: dateFormatter.string(from: model.createdAt)
        )
    }
    
    static func toCreateDTO(from model: AttendanceModel) -> CreateAttendanceDTO {
        return CreateAttendanceDTO(
            userId: model.userId,
            eventId: model.eventId,
            status: model.status.rawValue,
            userName: model.userName,
            userEmail: model.userEmail
        )
    }
}