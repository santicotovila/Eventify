import Foundation

protocol AttendanceRepositoryProtocol {
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel
    func getAttendances(for eventId: String) async throws -> [AttendanceModel]
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel?
}