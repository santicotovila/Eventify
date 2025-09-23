import Foundation

final class EventsRepository: EventsRepositoryProtocol {
    
    func getEvents(filter: String) async -> [EventModel] {
        let allEvents = [
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
        
        if filter.isEmpty {
            return allEvents
        } else {
            return allEvents.filter { event in
                event.title.lowercased().contains(filter.lowercased()) ||
                event.description.lowercased().contains(filter.lowercased())
            }
        }
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return true
    }
}

final class EventsRepositoryFake: EventsRepositoryProtocol {
    
    func getEvents(filter: String) async -> [EventModel] {
        return [EventModel.preview]
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        return true
    }
}