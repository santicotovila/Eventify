import Foundation
import SwiftData

final class SwiftDataEventsRepository: EventsRepositoryProtocol {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        let dataModel = EventDataModel(from: event)
        modelContext.insert(dataModel)
        
        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }
    
    func getEvents(filter: String) async -> [EventModel] {
        let descriptor = FetchDescriptor<EventDataModel>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            let dataModels = try modelContext.fetch(descriptor)
            let allEvents = dataModels.map { $0.toDomainModel() }
            
            if filter.isEmpty {
                return allEvents
            } else {
                return allEvents.filter { event in
                    event.title.lowercased().contains(filter.lowercased()) ||
                    event.description.lowercased().contains(filter.lowercased())
                }
            }
        } catch {
            return []
        }
    }
}