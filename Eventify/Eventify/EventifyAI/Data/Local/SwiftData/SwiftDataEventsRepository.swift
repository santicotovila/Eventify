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
    
    func deleteEvent(_ eventId: String) async -> Bool {
        do {
            let descriptor = FetchDescriptor<EventDataModel>(
                predicate: #Predicate { $0.id == eventId }
            )
            let events = try modelContext.fetch(descriptor)
            
            if let eventToDelete = events.first {
                modelContext.delete(eventToDelete)
                try modelContext.save()
                return true
            }
            
            return false
        } catch {
            return false
        }
    }
}