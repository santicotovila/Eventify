import Foundation

protocol NetworkAttendanceProtocol {
    func getAttendances(eventId: String) async throws -> [AttendanceModel]
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel?
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel
}

final class NetworkAttendance: NetworkAttendanceProtocol {
    
    private var mockAttendances: [AttendanceModel] {
        return [
            AttendanceModel(
                id: "attendance-1",
                userId: "user-1",
                eventId: "event-1",
                status: .going,
                userName: "Usuario Demo",
                userEmail: "demo@eventifyai.com",
                createdAt: Date()
            ),
            AttendanceModel(
                id: "attendance-2",
                userId: "user-2",
                eventId: "event-1",
                status: .maybe,
                userName: "Carlos Ruiz",
                userEmail: "carlos@eventifyai.com",
                createdAt: Date()
            ),
            AttendanceModel(
                id: "attendance-3",
                userId: "user-3",
                eventId: "event-2",
                status: .going,
                userName: "María López",
                userEmail: "maria@eventifyai.com",
                createdAt: Date()
            ),
            AttendanceModel(
                id: "attendance-4",
                userId: "user-1",
                eventId: "event-2",
                status: .notGoing,
                userName: "Usuario Demo",
                userEmail: "demo@eventifyai.com",
                createdAt: Date()
            )
        ]
    }
    
    func getAttendances(eventId: String) async throws -> [AttendanceModel] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        if Int.random(in: 1...20) == 1 {
            throw NetworkError.internalServerError
        }
        
        let eventAttendances = mockAttendances.filter { attendance in
            attendance.eventId == eventId
        }
        
        return eventAttendances
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return mockAttendances.first { attendance in
            attendance.userId == userId && attendance.eventId == eventId
        }
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel {
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
            let updatedAttendance = AttendanceModel(
                id: existingAttendance.id,
                userId: userId,
                eventId: eventId,
                status: status,
                userName: userName,
                userEmail: existingAttendance.userEmail,
                createdAt: existingAttendance.createdAt
            )
            return updatedAttendance
        } else {
            let userEmail = getUserEmail(userId: userId)
            let newAttendance = AttendanceModel(
                id: "attendance-\(UUID().uuidString)",
                userId: userId,
                eventId: eventId,
                status: status,
                userName: userName,
                userEmail: userEmail,
                createdAt: Date()
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