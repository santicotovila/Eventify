import Foundation
import SwiftData

final class SimpleEventsRepository: EventsRepositoryProtocol {
    
    private let swiftDataRepo: SwiftDataEventsRepository?
    private let networkRepo: NetworkEventsRepository?
    
    init(modelContext: ModelContext? = nil, enableNetwork: Bool = true) {
        if let context = modelContext {
            self.swiftDataRepo = SwiftDataEventsRepository(modelContext: context)
        } else {
            self.swiftDataRepo = nil
        }
        
        if enableNetwork {
            self.networkRepo = NetworkEventsRepository()
        } else {
            self.networkRepo = nil
        }
    }
    
    func getEvents(filter: String) async -> [EventModel] {
        // SOLO usar backend - ignorar eventos locales para evitar mocks de otros usuarios
        if let networkRepo = networkRepo {
            let backendEvents = await networkRepo.getEvents(filter: "")
            
            // DESHABILITADO: Sincronización con SwiftData para evitar threading issues
            // Usando solo backend por ahora
            // if let swiftDataRepo = swiftDataRepo {
            //     for backendEvent in backendEvents {
            //         _ = await swiftDataRepo.createEvent(backendEvent)
            //     }
            // }
            
            let filteredEvents = filter.isEmpty ? backendEvents : backendEvents.filter { event in
                event.title.lowercased().contains(filter.lowercased()) ||
                event.description.lowercased().contains(filter.lowercased()) ||
                event.location.lowercased().contains(filter.lowercased())
            }
            
            return filteredEvents.sorted { $0.date > $1.date }
        }
        
        // Fallback a local solo si no hay red
        if let swiftDataRepo = swiftDataRepo {
            let localEvents = await swiftDataRepo.getEvents(filter: filter)
            return localEvents.sorted { $0.date > $1.date }
        }
        
        return []
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        // DESHABILITADO: SwiftData por threading issues
        // Solo usar backend por ahora
        
        if let networkRepo = networkRepo {
            let result = await networkRepo.createEvent(event)
            return result
        }
        
        return false
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        // DESHABILITADO: SwiftData por threading issues
        // Solo usar backend por ahora
        
        if let networkRepo = networkRepo {
            return await networkRepo.deleteEvent(eventId)
        }
        
        return false
    }
}

/// Repository simple para network
final class NetworkEventsRepository: EventsRepositoryProtocol {
    private let networkEvents = NetworkEvents()
    
    func getEvents(filter: String) async -> [EventModel] {
        do {
            // Obtener el userID real del usuario autenticado
            guard let currentUser = KeyChainEventify.shared.getCurrentUser() else {
                return []
            }
            
            return try await networkEvents.getEvents(userId: currentUser.id)
        } catch {
            return []
        }
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        do {
            let result = try await networkEvents.createEvent(event: event)
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
