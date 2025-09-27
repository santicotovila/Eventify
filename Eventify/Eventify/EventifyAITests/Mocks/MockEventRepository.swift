import Foundation
@testable import EventifyAI

/// Mock del repositorio de eventos para tests
final class MockEventRepository: EventRepositoryProtocol {
    
    // MARK: - Test Properties
    var createEventCalled = false
    var getUserEventsCalled = false
    var getEventByIdCalled = false
    var saveAttendanceCalled = false
    var getAttendancesCalled = false
    
    // MARK: - Test Data
    var events: [String: Event] = [:]
    var attendances: [Attendance] = []
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.serverError(500)
    
    
    func createEvent(_ event: Event) async throws -> Event {
        createEventCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        events[event.id] = event
        return event
    }
    
    func getUserEvents(userId: String) async throws -> [Event] {
        getUserEventsCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return events.values.filter { $0.creatorId == userId }
    }
    
    func getEventById(_ id: String) async throws -> Event? {
        getEventByIdCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return events[id]
    }
    
    func saveAttendance(_ attendance: Attendance) async throws -> Attendance {
        saveAttendanceCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Remover asistencia previa del mismo usuario para el mismo evento
        attendances.removeAll { $0.eventId == attendance.eventId && $0.userId == attendance.userId }
        
        // Agregar nueva asistencia
        attendances.append(attendance)
        
        return attendance
    }
    
    func getAttendances(for eventId: String) async throws -> [Attendance] {
        getAttendancesCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return attendances.filter { $0.eventId == eventId }
    }
}