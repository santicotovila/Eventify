import Foundation

// Define qué operaciones puede hacer con eventos
protocol EventRepositoryProtocol {
    func createEvent(_ event: Event) async throws -> Event
    func getUserEvents(userId: String) async throws -> [Event]
    func getEventById(_ id: String) async throws -> Event?
    func saveAttendance(_ attendance: Attendance) async throws -> Attendance
    func getAttendances(for eventId: String) async throws -> [Attendance]
}

// Esta clase maneja los eventos en Firebase y los guarda localmente también
// Así funciona aunque no haya internet
final class EventRepository: EventRepositoryProtocol {
    
    // Cosas que necesita para funcionar
    private let firebaseDataSource: FirebaseDataSourceProtocol
    private let localDataSource: SwiftDataDataSourceProtocol
    
    // Constructor
    init(firebaseDataSource: FirebaseDataSourceProtocol, localDataSource: SwiftDataDataSourceProtocol) {
        self.firebaseDataSource = firebaseDataSource
        self.localDataSource = localDataSource
    }
    
    // Operaciones con eventos
    
    // Crea un evento en Firebase y también lo guarda localmente
    func createEvent(_ event: Event) async throws -> Event {
        // Guardarlo en Firebase (la fuente principal)
        let savedEvent = try await firebaseDataSource.createEvent(event)
        
        // Guardarlo también en el teléfono por si no hay internet
        try await localDataSource.saveEvent(savedEvent)
        
        return savedEvent
    }
    
    // Obtiene los eventos del usuario (intenta desde Firebase, si no funciona usa los locales)
    func getUserEvents(userId: String) async throws -> [Event] {
        do {
            // Intentar traer desde Firebase para tener lo más actualizado
            let remoteEvents = try await firebaseDataSource.getUserEvents(userId: userId)
            
            // Actualizar lo que tenemos guardado en el teléfono
            for event in remoteEvents {
                try await localDataSource.saveEvent(event)
            }
            
            return remoteEvents
        } catch {
            // Si falla la conexión, usar caché local
            print("Error obteniendo eventos remotos, usando caché local: \(error)")
            return try await localDataSource.getEvents(for: userId)
        }
    }
    
    /// Busca un evento por ID
    func getEventById(_ id: String) async throws -> Event? {
        // Intentar primero desde Firebase
        if let remoteEvent = try await firebaseDataSource.getEventById(id) {
            // Actualizar caché local
            try await localDataSource.saveEvent(remoteEvent)
            return remoteEvent
        }
        
        // Si no está en Firebase, buscar en caché local
        return try await localDataSource.getEventById(id)
    }
    
    // MARK: - Attendance Operations
    
    /// Guarda una respuesta de asistencia
    func saveAttendance(_ attendance: Attendance) async throws -> Attendance {
        // Guardar en Firebase
        let savedAttendance = try await firebaseDataSource.saveAttendance(attendance)
        
        // Guardar en caché local
        try await localDataSource.saveAttendance(savedAttendance)
        
        return savedAttendance
    }
    
    /// Obtiene todas las asistencias para un evento
    func getAttendances(for eventId: String) async throws -> [Attendance] {
        do {
            // Intentar obtener desde Firebase
            let remoteAttendances = try await firebaseDataSource.getAttendances(for: eventId)
            
            // Actualizar caché local
            for attendance in remoteAttendances {
                try await localDataSource.saveAttendance(attendance)
            }
            
            return remoteAttendances
        } catch {
            // Usar caché local si falla la conexión
            print("Error obteniendo asistencias remotas, usando caché local: \(error)")
            return try await localDataSource.getAttendances(for: eventId)
        }
    }
}