import Foundation

protocol NetworkAttendanceProtocol {
    func getAttendances(eventId: String) async throws -> [AttendanceDTO]
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceDTO?
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceDTO
}

final class NetworkAttendance: NetworkAttendanceProtocol {
    
    private let dateFormatter = ISO8601DateFormatter()
    
    private var mockAttendances: [AttendanceDTO] {
        let currentDate = dateFormatter.string(from: Date())
        
        return [
            AttendanceDTO(
                id: "attendance-1",
                userId: "user-1",
                eventId: "event-1",
                status: "going",
                userName: "Usuario Demo",
                userEmail: "demo@eventifyai.com",
                createdAt: currentDate
            ),
            AttendanceDTO(
                id: "attendance-2",
                userId: "user-2",
                eventId: "event-1",
                status: "maybe",
                userName: "Carlos Ruiz",
                userEmail: "carlos@eventifyai.com",
                createdAt: currentDate
            ),
            AttendanceDTO(
                id: "attendance-3",
                userId: "user-3",
                eventId: "event-2",
                status: "going",
                userName: "María López",
                userEmail: "maria@eventifyai.com",
                createdAt: currentDate
            ),
            AttendanceDTO(
                id: "attendance-4",
                userId: "user-1",
                eventId: "event-2",
                status: "notGoing",
                userName: "Usuario Demo",
                userEmail: "demo@eventifyai.com",
                createdAt: currentDate
            )
        ]
    }
    
    func getAttendances(eventId: String) async throws -> [AttendanceDTO] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        if Int.random(in: 1...20) == 1 {
            throw NetworkError.internalServerError
        }
        
        let eventAttendances = mockAttendances.filter { attendance in
            attendance.eventId == eventId
        }
        
        return eventAttendances
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceDTO? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return mockAttendances.first { attendance in
            attendance.userId == userId && attendance.eventId == eventId
        }
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceDTO {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard !userId.isEmpty else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        guard !eventId.isEmpty else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        // Actualizar si ya existe, crear si no existe
        if let existingAttendance = mockAttendances.first(where: { 
            $0.userId == userId && $0.eventId == eventId 
        }) {
            let updatedAttendance = AttendanceDTO(
                id: existingAttendance.id,
                userId: userId,
                eventId: eventId,
                status: status.rawValue,
                userName: userName,
                userEmail: existingAttendance.userEmail,
                createdAt: existingAttendance.createdAt
            )
            return updatedAttendance
        } else {
            let userEmail = getUserEmail(userId: userId)
            let currentDate = dateFormatter.string(from: Date())
            let newAttendance = AttendanceDTO(
                id: "attendance-\(UUID().uuidString)",
                userId: userId,
                eventId: eventId,
                status: status.rawValue,
                userName: userName,
                userEmail: userEmail,
                createdAt: currentDate
            )
            return newAttendance
        }
    }
    
    private func getUserEmail(userId: String) -> String {
        switch userId {
        case "user-1":
            return "demo@eventifyai.com"
        case "user-2":
            return "carlos@eventifyai.com"
        case "user-3":
            return "maria@eventifyai.com"
        default:
            return "unknown@eventifyai.com"
        }
    }
}

