//
//  EventsUseCase.swift
//  EventifyAI
//
//  Created by Javier Gómez on 8/9/25.
//

import Foundation
import SwiftData

protocol EventsUseCaseProtocol {
    var repo: EventsRepositoryProtocol { get set }
    func getEvents(filter: String) async -> [EventModel]
    func createEvent(_ event: EventModel) async -> Bool
    func deleteEvent(_ eventId: String) async -> Bool
}

final class EventsUseCase: EventsUseCaseProtocol {
    var repo: EventsRepositoryProtocol
    
    init(repo: EventsRepositoryProtocol? = nil, modelContext: ModelContext? = nil) {
        // Si no se pasa repo, usar el híbrido por defecto
        self.repo = repo ?? HybridEventsRepository(
            modelContext: modelContext,
            enableNetwork: true  // Habilitar backend por defecto
        )
    }
    
    func getEvents(filter: String) async -> [EventModel] {
        return await repo.getEvents(filter: filter)
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        return await repo.createEvent(event)
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        return await repo.deleteEvent(eventId)
    }
}

final class EventsUseCaseFake: EventsUseCaseProtocol {
    var repo: EventsRepositoryProtocol
    
    init(repo: EventsRepositoryProtocol = EventsRepositoryFake()) {
        self.repo = repo
    }
    
    func getEvents(filter: String) async -> [EventModel] {
        return await repo.getEvents(filter: filter)
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        return await repo.createEvent(event)
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        return await repo.deleteEvent(eventId)
    }
}