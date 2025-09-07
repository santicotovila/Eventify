import Foundation

// Define qué cosas puede hacer para votar en eventos
protocol VoteAttendanceUseCaseProtocol {
    func vote(eventId: String, status: AttendanceStatus) async throws -> Attendance
    func getAttendances(for eventId: String) async throws -> [Attendance]
    func getUserAttendance(eventId: String) async throws -> Attendance?
}

// Esta clase maneja cuando la gente vota si va a eventos
// Guarda los votos y te dice quién votó qué
final class VoteAttendanceUseCase: VoteAttendanceUseCaseProtocol {
    
    // Cosas que necesita para funcionar
    private let eventRepository: EventRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    
    // Constructor
    init(eventRepository: EventRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.eventRepository = eventRepository
        self.authRepository = authRepository
    }
    
    // Métodos principales
    
    // Guarda el voto de una persona (sí, no, o tal vez)
    func vote(eventId: String, status: AttendanceStatus) async throws -> Attendance {
        guard let currentUser = authRepository.getCurrentUser() else {
            throw EventError.userNotAuthenticated
        }
        
        // Revisar que el evento existe
        guard try await eventRepository.getEventById(eventId) != nil else {
            throw EventError.eventNotFound
        }
        
        // Crear el voto de la persona
        let attendance = Attendance(
            eventId: eventId,
            userId: currentUser.id,
            userEmail: currentUser.email,
            status: status
        )
        
        return try await eventRepository.saveAttendance(attendance)
    }
    
    // Trae todos los votos de un evento
    func getAttendances(for eventId: String) async throws -> [Attendance] {
        return try await eventRepository.getAttendances(for: eventId)
    }
    
    // Busca el voto de la persona que está logueada para un evento
    func getUserAttendance(eventId: String) async throws -> Attendance? {
        guard let currentUser = authRepository.getCurrentUser() else {
            return nil
        }
        
        let attendances = try await getAttendances(for: eventId)
        return attendances.first { $0.userId == currentUser.id }
    }
}