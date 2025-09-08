import Foundation

final class DefaultAttendanceRepository: AttendanceRepositoryProtocol {
    
    private let networkAttendance: NetworkAttendanceProtocol
    private let keychain: kcPersistenceKeyChain
    
    init(
        networkAttendance: NetworkAttendanceProtocol = NetworkAttendance(),
        keychain: kcPersistenceKeyChain = .shared
    ) {
        self.networkAttendance = networkAttendance
        self.keychain = keychain
    }
    
    func getAttendances(for eventId: String) async throws -> [AttendanceModel] {
        do {
            let attendanceDTOs = try await networkAttendance.getAttendances(eventId: eventId)
            let attendances = attendanceDTOs.compactMap { AttendanceMapper.toModel(from: $0) }
            return attendances
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel? {
        do {
            guard let attendanceDTO = try await networkAttendance.getUserAttendance(userId: userId, eventId: eventId) else {
                return nil
            }
            return AttendanceMapper.toModel(from: attendanceDTO)
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel {
        do {
            let attendanceDTO = try await networkAttendance.saveAttendance(
                userId: userId,
                eventId: eventId,
                status: status,
                userName: userName
            )
            guard let attendance = AttendanceMapper.toModel(from: attendanceDTO) else {
                throw DomainError.mappingFailed("No se pudo convertir AttendanceDTO a AttendanceModel")
            }
            return attendance
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch let domainError as DomainError {
            throw domainError
        } catch {
            throw EventError.attendanceUpdateFailed
        }
    }
    
    private func getCurrentUserId() -> String? {
        return keychain.getString(key: ConstantsApp.Keychain.currentUserId)
    }
}
