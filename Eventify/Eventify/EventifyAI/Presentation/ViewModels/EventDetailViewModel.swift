import Foundation

@MainActor
@Observable
final class EventDetailViewModel {
    
    var event: EventModel?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let eventId: String
    @ObservationIgnored
    private let eventsUseCase: EventsUseCaseProtocol
    
    init(eventId: String, eventsUseCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.eventId = eventId
        self.eventsUseCase = eventsUseCase
    }
    
    func loadEventDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allEvents = await eventsUseCase.getEvents(filter: "")
            print("Buscando evento con ID: \(eventId)")
            print("Eventos disponibles: \(allEvents.count)")
            for event in allEvents {
                print("  - ID: \(event.id), Título: \(event.title)")
            }
            
            self.event = allEvents.first { $0.id == eventId }
            
            if let foundEvent = self.event {
                print("Evento encontrado: \(foundEvent.title)")
            } else {
                print("No se encontró evento con ID: \(eventId)")
                errorMessage = "No se pudo encontrar el evento con ID: \(eventId)"
            }
        } catch {
            print("Error cargando eventos: \(error)")
            errorMessage = "Error al cargar el evento: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
