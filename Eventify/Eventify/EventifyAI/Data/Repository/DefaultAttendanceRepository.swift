import Foundation

final class DefaultAttendanceRepository: AttendanceRepositoryProtocol {
    
    private let networkAttendance: NetworkAttendanceProtocol
    private let keychain: KeyChainEventify
    
    init(
        networkAttendance: NetworkAttendanceProtocol = NetworkAttendance(),
        keychain: KeyChainEventify = .shared
    ) {
        self.networkAttendance = networkAttendance
        self.keychain = keychain
    }
    
    func getAttendances(for eventId: String) async throws -> [AttendanceModel] {
        do {
            let attendances = try await networkAttendance.getAttendances(eventId: eventId)
            return attendances
        } catch let networkError as NetworkError {
            throw AttendanceError.networkError(networkError)
        } catch {
            throw AttendanceError.unknown(error)
        }
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel? {
        do {
            let attendance = try await networkAttendance.getUserAttendance(userId: userId, eventId: eventId)
            return attendance
        } catch let networkError as NetworkError {
            throw AttendanceError.networkError(networkError)
        } catch {
            throw AttendanceError.unknown(error)
        }
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel {
        do {
            let attendance = try await networkAttendance.saveAttendance(
                userId: userId,
                eventId: eventId,
                status: status,
                userName: userName
            )
            return attendance
        } catch let networkError as NetworkError {
            throw AttendanceError.networkError(networkError)
        } catch {
            throw AttendanceError.unknown(error)
        }
    }
}