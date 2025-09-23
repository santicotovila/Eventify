import Foundation


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
    private let eventsUseCase: EventsUseCaseProtocol
    
    init(eventsUseCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.eventsUseCase = eventsUseCase
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
        } else {
            errorMessage = "Error al crear el evento"
        }
        
        isLoading = false
    }
}
