
import Foundation

final class EventsRepository: EventsRepositoryProtocol {
    
    // Persistencia en memoria para desarrollo/testing
    private var events: [EventModel] = [
        EventModel.preview,
        EventModel.previewPast,
        EventModel(
            id: "conference-ios-1",
            title: "Conferencia iOS",
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            location: "Madrid",
            organizerId: "user-3",
            organizerName: "Keepcoding",
            tags: ["iOS", "desarrollo"]
        )
    ]
    
    func getEvents(filter: String) async -> [EventModel] {
        // Simular delay de red
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if filter.isEmpty {
            return events.sorted { $0.date > $1.date } // Más recientes primero
        } else {
            return events.filter { event in
                event.title.lowercased().contains(filter.lowercased()) ||
                event.location.lowercased().contains(filter.lowercased()) ||
                (event.category?.lowercased().contains(filter.lowercased()) ?? false)
            }.sorted { $0.date > $1.date }
        }
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        // Simular delay de red
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // GUARDAR en array en memoria
        events.append(event)
        
        return true
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        // Este repository ya no se usa directamente
        // Solo está para compatibilidad
        return false
    }
}

final class EventsRepositoryFake: EventsRepositoryProtocol {
    
    func getEvents(filter: String) async -> [EventModel] {
        return [EventModel.preview]
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        return true
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        return true
    }
}
