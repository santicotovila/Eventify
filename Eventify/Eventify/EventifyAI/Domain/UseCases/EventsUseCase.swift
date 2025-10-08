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
        self.repo = repo ?? SimpleEventsRepository(
            modelContext: modelContext,
            enableNetwork: true
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
