import Foundation
import Combine

@Observable
final class EventsViewModel {
    var eventsData = [EventModel]()
    var filterUI: String = ""
    
    @ObservationIgnored
    private var useCaseEvents: EventsUseCaseProtocol
    
    init(useCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.useCaseEvents = useCase
        Task {
            await self.getEvents()
        }
    }
    
    @MainActor
    func getEvents(newSearch: String = "") async {
        let data = await useCaseEvents.getEvents(filter: newSearch)
        self.eventsData = data
    }
    
    @MainActor
    func createEvent(_ event: EventModel) async -> Bool {
        let success = await useCaseEvents.createEvent(event)
        
        if success {
            await getEvents()
        }
        
        return success
    }
}