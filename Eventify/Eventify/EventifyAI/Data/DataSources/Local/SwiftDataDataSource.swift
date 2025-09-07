import Foundation
import SwiftData

/// Protocolo que define las operaciones locales con SwiftData
protocol SwiftDataDataSourceProtocol {
    func saveEvent(_ event: Event) async throws
    func getEvents(for userId: String) async throws -> [Event]
    func getEventById(_ id: String) async throws -> Event?
    func saveAttendance(_ attendance: Attendance) async throws
    func getAttendances(for eventId: String) async throws -> [Attendance]
    func clearCache() async throws
}

/// Implementación del data source local usando SwiftData
@MainActor
final class SwiftDataDataSource: SwiftDataDataSourceProtocol {
    
    // MARK: - Properties
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext {
        modelContainer.mainContext
    }
    
    // MARK: - Initialization
    init() throws {
        // Configurar el contenedor de SwiftData con nuestros modelos
        modelContainer = try ModelContainer(for: EventDataModel.self, AttendanceDataModel.self)
    }
    
    // MARK: - Event Operations
    
    /// Guarda un evento en la base de datos local
    func saveEvent(_ event: Event) async throws {
        // Verificar si ya existe y actualizarlo
        let existingEventDescriptor = FetchDescriptor<EventDataModel>(
            predicate: #Predicate<EventDataModel> { $0.id == event.id }
        )
        
        if let existingEvent = try modelContext.fetch(existingEventDescriptor).first {
            // Actualizar evento existente
            existingEvent.title = event.title
            existingEvent.eventDescription = event.description
            existingEvent.dateTime = event.dateTime
            existingEvent.location = event.location
            existingEvent.updatedAt = event.updatedAt
        } else {
            // Crear nuevo evento
            let eventDataModel = EventDataModel(from: event)
            modelContext.insert(eventDataModel)
        }
        
        try modelContext.save()
    }
    
    /// Obtiene eventos del usuario desde la base de datos local
    func getEvents(for userId: String) async throws -> [Event] {
        let descriptor = FetchDescriptor<EventDataModel>(
            predicate: #Predicate<EventDataModel> { $0.creatorId == userId },
            sortBy: [SortDescriptor(\.dateTime)]
        )
        
        let eventDataModels = try modelContext.fetch(descriptor)
        return eventDataModels.map { $0.toEvent() }
    }
    
    /// Busca un evento por ID en la base de datos local
    func getEventById(_ id: String) async throws -> Event? {
        let descriptor = FetchDescriptor<EventDataModel>(
            predicate: #Predicate<EventDataModel> { $0.id == id }
        )
        
        guard let eventDataModel = try modelContext.fetch(descriptor).first else {
            return nil
        }
        
        return eventDataModel.toEvent()
    }
    
    // MARK: - Attendance Operations
    
    /// Guarda una asistencia en la base de datos local
    func saveAttendance(_ attendance: Attendance) async throws {
        // Verificar si ya existe una asistencia del mismo usuario para el mismo evento
        let existingDescriptor = FetchDescriptor<AttendanceDataModel>(
            predicate: #Predicate<AttendanceDataModel> { 
                $0.eventId == attendance.eventId && $0.userId == attendance.userId 
            }
        )
        
        if let existingAttendance = try modelContext.fetch(existingDescriptor).first {
            // Actualizar asistencia existente
            existingAttendance.status = attendance.status.rawValue
            existingAttendance.respondedAt = attendance.respondedAt
        } else {
            // Crear nueva asistencia
            let attendanceDataModel = AttendanceDataModel(from: attendance)
            modelContext.insert(attendanceDataModel)
        }
        
        try modelContext.save()
    }
    
    /// Obtiene asistencias para un evento desde la base de datos local
    func getAttendances(for eventId: String) async throws -> [Attendance] {
        let descriptor = FetchDescriptor<AttendanceDataModel>(
            predicate: #Predicate<AttendanceDataModel> { $0.eventId == eventId },
            sortBy: [SortDescriptor(\.respondedAt)]
        )
        
        let attendanceDataModels = try modelContext.fetch(descriptor)
        return attendanceDataModels.compactMap { $0.toAttendance() }
    }
    
    /// Limpia toda la caché local (útil para cerrar sesión)
    func clearCache() async throws {
        // Eliminar todos los eventos
        try modelContext.delete(model: EventDataModel.self)
        
        // Eliminar todas las asistencias
        try modelContext.delete(model: AttendanceDataModel.self)
        
        try modelContext.save()
    }
}