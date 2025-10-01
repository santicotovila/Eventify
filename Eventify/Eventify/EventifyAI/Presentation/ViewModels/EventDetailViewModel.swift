import Foundation
import SwiftData

@MainActor
@Observable
final class EventDetailViewModel {
    
    var event: EventModel?
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let eventId: String
    @ObservationIgnored
    private var eventsUseCase: EventsUseCaseProtocol
    
    init(eventId: String, eventsUseCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.eventId = eventId
        self.eventsUseCase = eventsUseCase
    }
    
    // Método para inyectar modelContext después de init
    func setModelContext(_ modelContext: ModelContext) {
        // Recrear UseCase con contexto
        self.eventsUseCase = EventsUseCase(modelContext: modelContext)
    }
    
    func loadEventDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let allEvents = await eventsUseCase.getEvents(filter: "")
            
            self.event = allEvents.first { $0.id == eventId }
            
            if self.event == nil {
                errorMessage = "No se pudo encontrar el evento con ID: \(eventId)"
            }
        } catch {
            errorMessage = "Error al cargar el evento: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteEvent() async -> Bool {
        guard let event = event else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let success = await eventsUseCase.deleteEvent(event.id)
        
        if success {
        } else {
            errorMessage = "No se pudo eliminar el evento"
        }
        
        isLoading = false
        return success
    }
}
