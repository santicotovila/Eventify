//
// CreateEventViewModel.swift
// EventifyAI
//
// Nota para los compis del bootcamp:
//
// Este ViewModel es el cerebro detrás del formulario para crear un nuevo evento (`CreateEventView`).
// Es un buen ejemplo de un ViewModel enfocado en una sola tarea.
// Su misión es recoger los datos que el usuario introduce en los campos de texto y el selector de fecha.
//

import Foundation

@MainActor
final class CreateEventViewModel: ObservableObject {
    
    // MARK: - Propiedades Vinculadas al Formulario
    // Estas propiedades están conectadas directamente con los `TextFields` y el `DatePicker` de la vista.
    // Gracias a `@Published`, cualquier cosa que el usuario escriba en la vista, se actualiza aquí al instante.
    
    @Published var eventTitle: String = ""
    @Published var eventDescription: String = ""
    @Published var eventLocation: String = ""
    @Published var eventDate: Date = Date().addingTimeInterval(3600) // Por defecto, la fecha es una hora en el futuro.
    
    // MARK: - Propiedades de Estado de la UI
    // Estas propiedades nos ayudan a controlar la interfaz de usuario mientras se crea el evento.
    
    @Published var isLoading: Bool = false // Para mostrar una animación de carga.
    @Published var errorMessage: String? = nil // Para mostrar un mensaje si algo sale mal.
    @Published var isEventCreated: Bool = false // Lo ponemos a `true` cuando el evento se crea con éxito, para que la vista se pueda cerrar.
    
    // MARK: - Dependencias
    
    private let eventsUseCase: EventsUseCaseProtocol // El caso de uso que sabe cómo guardar un evento nuevo.
    
    // MARK: - Inicializador
    
    init(eventsUseCase: EventsUseCaseProtocol) {
        self.eventsUseCase = eventsUseCase
    }
    
    // MARK: - Lógica de Creación
    
    // Esta función se llama cuando el usuario pulsa el botón "Crear".
    func createEvent() async {
        isLoading = true
        errorMessage = nil
        
        // 1. Creamos un objeto `EventModel` con los datos que hemos recogido de los @Published.
        // Nota: El `organizerId` y `organizerName` no los ponemos aquí. El `EventsUseCase` se encargará
        // de asignarlos cogiendo los datos del usuario que tiene la sesión iniciada. Esto es más seguro.
        let newEvent = EventModel(
            title: eventTitle,
            description: eventDescription,
            date: eventDate,
            location: eventLocation,
            organizerId: "",
            organizerName: ""
        )
        
        // 2. Intentamos crear el evento llamando al caso de uso.
        do {
            _ = try await eventsUseCase.createEvent(newEvent)
            // 3. Si todo va bien, marcamos `isEventCreated` como true.
            // La vista (`CreateEventView`) está observando esta variable y se cerrará (dismiss) cuando cambie a true.
            isEventCreated = true
        } catch {
            // 4. Si hay un error, lo guardamos para que la vista muestre una alerta.
            errorMessage = "Error al crear el evento: \(error.localizedDescription)"
        }
        
        // 5. Pase lo que pase, dejamos de cargar.
        isLoading = false
    }
}