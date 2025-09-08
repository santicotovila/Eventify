import Foundation

struct EventDTO: Codable {
    let id: String
    let title: String
    let description: String
    let date: String
    let location: String
    let organizerId: String
    let organizerName: String
    let isAllDay: Bool
    let tags: [String]
    let maxAttendees: Int?
    let createdAt: String
    let updatedAt: String
}

struct CreateEventDTO: Codable {
    let title: String
    let description: String
    let date: String
    let location: String
    let organizerId: String
    let organizerName: String
    let isAllDay: Bool
    let tags: [String]
    let maxAttendees: Int?
}

struct UpdateEventDTO: Codable {
    let title: String?
    let description: String?
    let date: String?
    let location: String?
    let isAllDay: Bool?
    let tags: [String]?
    let maxAttendees: Int?
}