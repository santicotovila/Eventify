import Foundation
import SwiftData

/// Repository híbrido: Mocks ficticios + SwiftData + Backend para eventos reales
final class HybridEventsRepository: EventsRepositoryProtocol {
    
    // Eventos ficticios para demo/presentación (hardcodeados)
    private let mockEvents = [
        EventModel.preview,
        EventModel.previewPast,
        EventModel(
            id: "conference-ios-1", 
            title: "Conferencia iOS",
            description: "Conferencia sobre desarrollo iOS",
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            location: "Madrid",
            organizerId: "user-3",
            organizerName: "Keepcoding",
            tags: ["iOS", "desarrollo"]
        )
    ]
    
    // Eventos reales creados (fallback si no hay SwiftData)
    private var realEvents: [EventModel] = []
    
    // SwiftData para persistencia local de eventos nuevos
    private let swiftDataRepo: SwiftDataEventsRepository?
    
    // Network para backend de eventos nuevos
    private let networkRepo: NetworkEventsRepository?
    
    init(modelContext: ModelContext? = nil, enableNetwork: Bool = true) {
        // SwiftData si hay contexto
        if let context = modelContext {
            self.swiftDataRepo = SwiftDataEventsRepository(modelContext: context)
        } else {
            self.swiftDataRepo = nil
        }
        
        // Network habilitado por defecto
        if enableNetwork {
            self.networkRepo = NetworkEventsRepository()
        } else {
            self.networkRepo = nil
        }
        
        print("HybridRepository: MocksDemo=SI, SwiftData=\(swiftDataRepo != nil ? "SI" : "NO"), Network=\(networkRepo != nil ? "SI" : "NO")")
    }
    
    func getEvents(filter: String) async -> [EventModel] {
        var allEvents: [EventModel] = []
        
        // 1. Siempre incluir mocks ficticios para demo
        allEvents.append(contentsOf: mockEvents)
        
        // 2. Agregar eventos reales
        if let swiftDataRepo = swiftDataRepo {
            // Desde SwiftData si está disponible
            let swiftDataEvents = await swiftDataRepo.getEvents(filter: "")
            allEvents.append(contentsOf: swiftDataEvents)
        } else {
            // Desde memoria si no hay SwiftData
            allEvents.append(contentsOf: realEvents)
        }
        
        // Filtrar y ordenar
        let filteredEvents = filter.isEmpty ? allEvents : allEvents.filter { event in
            event.title.lowercased().contains(filter.lowercased()) ||
            event.description.lowercased().contains(filter.lowercased()) ||
            event.location.lowercased().contains(filter.lowercased())
        }
        
        return filteredEvents.sorted { $0.date > $1.date }
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        var swiftDataSuccess = false
        var networkSuccess = false
        
        // 1. Guardar en SwiftData (persistencia local)
        if let swiftDataRepo = swiftDataRepo {
            swiftDataSuccess = await swiftDataRepo.createEvent(event)
            if swiftDataSuccess {
                print("Evento guardado en SwiftData: '\(event.title)'")
            } else {
                print("SwiftData falló para: '\(event.title)'")
            }
        } else {
            print("SwiftData no disponible - guardando en memoria")
            // Guardar en array en memoria como fallback
            realEvents.append(event)
            swiftDataSuccess = true
            print("Evento guardado en memoria: '\(event.title)'")
        }
        
        // 2. Enviar a Backend (sincronización)
        if let networkRepo = networkRepo {
            networkSuccess = await networkRepo.createEvent(event)
            if networkSuccess {
                print("Evento enviado al Backend: '\(event.title)'")
            } else {
                print("Backend falló para: '\(event.title)'")
            }
        } else {
            print("Network no disponible")
            networkSuccess = true // Si no hay network, no es error
        }
        
        // Éxito si al menos uno funciona
        let finalSuccess = swiftDataSuccess || networkSuccess
        print("Resultado final createEvent: \(finalSuccess)")
        return finalSuccess
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        // Solo borrar eventos reales (no mocks ficticios)
        // Los mocks tienen IDs específicos que no se pueden borrar
        let protectedIds = ["preview-event-1", "preview-event-2", "conference-ios-1"]
        
        if protectedIds.contains(eventId) {
            print("No se puede borrar evento de demo: \(eventId)")
            return false
        }
        
        var success = false
        
        // 1. Borrar de SwiftData
        if let swiftDataRepo = swiftDataRepo {
            success = await swiftDataRepo.deleteEvent(eventId)
            if success {
                print("Evento borrado de SwiftData: \(eventId)")
            }
        }
        
        // 2. Borrar del Backend
        if let networkRepo = networkRepo {
            let networkSuccess = await networkRepo.deleteEvent(eventId)
            if networkSuccess {
                print("Evento borrado del Backend: \(eventId)")
            } else {
                print("Backend falló al borrar, pero SwiftData funcionó")
            }
        }
        
        return success
    }
}

/// Repository simple para network
final class NetworkEventsRepository: EventsRepositoryProtocol {
    private let networkEvents = NetworkEvents()
    
    func getEvents(filter: String) async -> [EventModel] {
        do {
            // Obtener el userID real del usuario autenticado
            guard let currentUser = KeyChainEventify.shared.getCurrentUser() else {
                print("No hay usuario autenticado")
                return []
            }
            
            return try await networkEvents.getEvents(userId: currentUser.id)
        } catch {
            print("Error al obtener eventos del backend: \(error)")
            return []
        }
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        do {
            _ = try await networkEvents.createEvent(event: event)
            return true
        } catch {
            return false
        }
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        do {
            try await networkEvents.deleteEvent(eventId: eventId)
            return true
        } catch {
            return false
        }
    }
}