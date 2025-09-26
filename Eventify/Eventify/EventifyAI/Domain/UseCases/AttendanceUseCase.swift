import Foundation

struct AttendanceStats {
    let totalAttendees: Int
    let going: Int
    let maybe: Int
    let notGoing: Int
}

protocol AttendanceUseCaseProtocol {
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel
    func getAttendances(for eventId: String) async throws -> [AttendanceModel]
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel?
    func updateAttendance(_ attendance: AttendanceModel) async throws -> AttendanceModel
    func getAttendanceStats(for eventId: String) async throws -> AttendanceStats
    func hasUserResponded(userId: String, eventId: String) async -> Bool
}

final class AttendanceUseCase: AttendanceUseCaseProtocol {
    
    private let attendanceRepository: AttendanceRepositoryProtocol
    private let loginRepository: LoginRepositoryProtocol
    private let eventsRepository: EventsRepositoryProtocol
    
    init(
        attendanceRepository: AttendanceRepositoryProtocol,
        loginRepository: LoginRepositoryProtocol,
        eventsRepository: EventsRepositoryProtocol
    ) {
        self.attendanceRepository = attendanceRepository
        self.loginRepository = loginRepository
        self.eventsRepository = eventsRepository
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel {
        guard let currentUser = loginRepository.getCurrentUser() else {
            throw AttendanceUseCaseError.userNotAuthenticated
        }
        
        guard userId == currentUser.id else {
            throw AttendanceUseCaseError.notAuthorized
        }
        
        // Buscar evento en la lista simple
        let allEvents = await eventsRepository.getEvents(filter: "")
        guard let event = allEvents.first(where: { $0.id == eventId }) else {
            throw AttendanceUseCaseError.eventNotFound
        }
        
        guard event.date > Date() else {
            throw AttendanceUseCaseError.eventAlreadyPassed
        }
        
        do {
            return try await attendanceRepository.saveAttendance(
                userId: userId,
                eventId: eventId,
                status: status,
                userName: userName
            )
        } catch {
            throw AttendanceUseCaseError.saveFailed(error)
        }
    }
    
    func getAttendances(for eventId: String) async throws -> [AttendanceModel] {
        guard loginRepository.getCurrentUser() != nil else {
            throw AttendanceUseCaseError.userNotAuthenticated
        }
        
        do {
            let attendances = try await attendanceRepository.getAttendances(for: eventId)
            let sortedAttendances = attendances.sorted { $0.createdAt > $1.createdAt }
            return sortedAttendances
        } catch {
            throw AttendanceUseCaseError.fetchFailed(error)
        }
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel? {
        guard loginRepository.getCurrentUser() != nil else {
            throw AttendanceUseCaseError.userNotAuthenticated
        }
        
        do {
            return try await attendanceRepository.getUserAttendance(userId: userId, eventId: eventId)
        } catch {
            throw AttendanceUseCaseError.fetchFailed(error)
        }
    }
    
    func updateAttendance(_ attendance: AttendanceModel) async throws -> AttendanceModel {
        guard let currentUser = loginRepository.getCurrentUser() else {
            throw AttendanceUseCaseError.userNotAuthenticated
        }
        
        guard attendance.userId == currentUser.id else {
            throw AttendanceUseCaseError.notAuthorized
        }
        
        // Buscar evento en la lista simple
        let allEvents = await eventsRepository.getEvents(filter: "")
        guard let event = allEvents.first(where: { $0.id == attendance.eventId }) else {
            throw AttendanceUseCaseError.eventNotFound
        }
        
        guard event.date > Date() else {
            throw AttendanceUseCaseError.eventAlreadyPassed
        }
        
        do {
            return try await attendanceRepository.saveAttendance(
                userId: attendance.userId,
                eventId: attendance.eventId,
                status: attendance.status,
                userName: attendance.userName
            )
        } catch {
            throw AttendanceUseCaseError.updateFailed(error)
        }
    }
    
    func getAttendanceStats(for eventId: String) async throws -> AttendanceStats {
        guard loginRepository.getCurrentUser() != nil else {
            throw AttendanceUseCaseError.userNotAuthenticated
        }
        
        do {
            let attendances = try await attendanceRepository.getAttendances(for: eventId)
            
            let going = attendances.filter { $0.status == .going }.count
            let maybe = attendances.filter { $0.status == .maybe }.count
            let notGoing = attendances.filter { $0.status == .notGoing }.count
            
            return AttendanceStats(
                totalAttendees: attendances.count,
                going: going,
                maybe: maybe,
                notGoing: notGoing
            )
        } catch {
            throw AttendanceUseCaseError.statsFailed(error)
        }
    }
    
    func hasUserResponded(userId: String, eventId: String) async -> Bool {
        do {
            let userAttendance = try await getUserAttendance(userId: userId, eventId: eventId)
            return userAttendance != nil
        } catch {
            return false
        }
    }
    
    func toggleUserAttendance(userId: String, eventId: String, currentStatus: AttendanceStatus, userName: String) async throws -> AttendanceModel {
        let newStatus: AttendanceStatus
        
        switch currentStatus {
        case .going:
            newStatus = .maybe
        case .maybe:
            newStatus = .notGoing
        case .notGoing:
            newStatus = .going
        }
        
        if let existingAttendance = try await getUserAttendance(userId: userId, eventId: eventId) {
            var updatedAttendance = existingAttendance
            updatedAttendance.id = existingAttendance.id
            
            let newAttendance = AttendanceModel(
                id: existingAttendance.id,
                userId: userId,
                eventId: eventId,
                status: newStatus,
                userName: userName,
                userEmail: existingAttendance.userEmail,
                createdAt: existingAttendance.createdAt
            )
            
            return try await attendanceRepository.saveAttendance(
                userId: userId,
                eventId: eventId,
                status: newStatus,
                userName: userName
            )
        } else {
            return try await saveAttendance(userId: userId, eventId: eventId, status: newStatus, userName: userName)
        }
    }
    
    func getEventAttendanceInfo(eventId: String) async throws -> EventAttendanceInfo {
        let stats = try await getAttendanceStats(for: eventId)
        let attendances = try await getAttendances(for: eventId)
        
        return EventAttendanceInfo(
            stats: stats,
            attendances: attendances,
            goingUsers: attendances.filter { $0.status == .going },
            maybeUsers: attendances.filter { $0.status == .maybe },
            notGoingUsers: attendances.filter { $0.status == .notGoing }
        )
    }
}

struct EventAttendanceInfo {
    let stats: AttendanceStats
    let attendances: [AttendanceModel]
    let goingUsers: [AttendanceModel]
    let maybeUsers: [AttendanceModel]
    let notGoingUsers: [AttendanceModel]
}

enum AttendanceUseCaseError: Error, LocalizedError {
    case userNotAuthenticated
    case notAuthorized
    case eventNotFound
    case eventAlreadyPassed
    case saveFailed(Error)
    case fetchFailed(Error)
    case updateFailed(Error)
    case statsFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Debes iniciar sesión para gestionar asistencias"
        case .notAuthorized:
            return "No tienes permisos para realizar esta acción"
        case .eventNotFound:
            return "Evento no encontrado"
        case .eventAlreadyPassed:
            return "No puedes modificar la asistencia a un evento que ya pasó"
        case .saveFailed(let error):
            return "Error al guardar asistencia: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Error al obtener asistencias: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Error al actualizar asistencia: \(error.localizedDescription)"
        case .statsFailed(let error):
            return "Error al obtener estadísticas: \(error.localizedDescription)"
        }
    }
}
