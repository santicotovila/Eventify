import Foundation
import SwiftData

@Observable
final class CreateEventViewModel {
    
    var eventTitle: String = ""
    var eventDescription: String = ""
    var eventLocation: String = ""
    var eventDate: Date = Date().addingTimeInterval(3600)
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isEventCreated: Bool = false
    
    var isFormValid: Bool {
        return !eventTitle.isEmpty && !eventDescription.isEmpty && !eventLocation.isEmpty
    }
    
    @ObservationIgnored
    private var eventsUseCase: EventsUseCaseProtocol
    
    init(eventsUseCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.eventsUseCase = eventsUseCase
    }
    
    // Método para inyectar modelContext después de init
    func setModelContext(_ modelContext: ModelContext) {
        // Recrear UseCase con contexto
        self.eventsUseCase = EventsUseCase(modelContext: modelContext)
    }
    @MainActor
    func createEvent() async {
        isLoading = true
        errorMessage = nil
        
        let newEvent = EventModel(
            title: eventTitle,
            description: eventDescription,
            date: eventDate,
            location: eventLocation,
            organizerId: "user-1",
            organizerName: "Usuario"
        )
        
        let success = await eventsUseCase.createEvent(newEvent)
        if success {
            isEventCreated = true
            // Notificar que se creó un evento para actualizar listas
            NotificationCenter.default.postEventWasCreated(event: newEvent)
        } else {
            errorMessage = "Error al crear el evento"
        }
        
        isLoading = false
    }
}
