import Foundation

struct EventMapper {
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static func toModel(from dto: EventDTO) -> EventModel? {
        guard let date = dateFormatter.date(from: dto.date),
              let createdAt = dateFormatter.date(from: dto.createdAt),
              let updatedAt = dateFormatter.date(from: dto.updatedAt) else {
            return nil
        }
        
        return EventModel(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            date: date,
            location: dto.location,
            organizerId: dto.organizerId,
            organizerName: dto.organizerName,
            isAllDay: dto.isAllDay,
            tags: dto.tags,
            maxAttendees: dto.maxAttendees,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func toDTO(from model: EventModel) -> EventDTO {
        return EventDTO(
            id: model.id,
            title: model.title,
            description: model.description,
            date: dateFormatter.string(from: model.date),
            location: model.location,
            organizerId: model.organizerId,
            organizerName: model.organizerName,
            isAllDay: model.isAllDay,
            tags: model.tags,
            maxAttendees: model.maxAttendees,
            createdAt: dateFormatter.string(from: model.createdAt),
            updatedAt: dateFormatter.string(from: model.updatedAt)
        )
    }
    
    static func toCreateDTO(from model: EventModel) -> CreateEventDTO {
        return CreateEventDTO(
            title: model.title,
            description: model.description,
            date: dateFormatter.string(from: model.date),
            location: model.location,
            organizerId: model.organizerId,
            organizerName: model.organizerName,
            isAllDay: model.isAllDay,
            tags: model.tags,
            maxAttendees: model.maxAttendees
        )
    }
}