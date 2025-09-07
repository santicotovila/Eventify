import Foundation

// Esta clase maneja la creación de eventos nuevos
@MainActor
final class CreateEventViewModel: ObservableObject {
    
    // Variables que la pantalla puede ver y cambiar
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var selectedDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @Published var createState: LoadingState<Event> = .idle
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // Cosas que necesita para funcionar
    private let createEventUseCase: CreateEventUseCaseProtocol
    
    // Variables calculadas
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedDate > Date()
    }
    
    var minimumDate: Date {
        Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
    }
    
    // Constructor
    init(createEventUseCase: CreateEventUseCaseProtocol) {
        self.createEventUseCase = createEventUseCase
    }
    
    // Métodos que usa la pantalla
    
    // Crea un evento nuevo con los datos del formulario
    func createEvent() async {
        guard isFormValid else {
            showError("Por favor completa todos los campos correctamente")
            return
        }
        
        createState = .loading
        
        do {
            let event = try await createEventUseCase.execute(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                dateTime: selectedDate,
                location: location.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            createState = .success(event)
            clearForm()
            
        } catch {
            createState = .failure(error)
            showError(error.localizedDescription)
        }
    }
    
    // Borra todo el formulario
    func clearForm() {
        title = ""
        description = ""
        location = ""
        selectedDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        createState = .idle
    }
    
    // Métodos internos
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}