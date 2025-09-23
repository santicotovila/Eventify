import Foundation

protocol EventsUseCaseProtocol {
    var repo: EventsRepositoryProtocol { get set }
    func getEvents(filter: String) async -> [EventModel]
    func createEvent(_ event: EventModel) async -> Bool
}

final class EventsUseCase: EventsUseCaseProtocol {
    var repo: EventsRepositoryProtocol
    
    init(repo: EventsRepositoryProtocol = EventsRepository()) {
        self.repo = repo
    }
    
    func getEvents(filter: String) async -> [EventModel] {
        return await repo.getEvents(filter: filter)
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        return await repo.createEvent(event)
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
}