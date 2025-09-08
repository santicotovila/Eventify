import Foundation

struct AttendanceDTO: Codable {
    let id: String
    let userId: String
    let eventId: String
    let status: String
    let userName: String
    let userEmail: String
    let createdAt: String
}

struct CreateAttendanceDTO: Codable {
    let userId: String
    let eventId: String
    let status: String
    let userName: String
    let userEmail: String
}

struct UpdateAttendanceDTO: Codable {
    let status: String
}