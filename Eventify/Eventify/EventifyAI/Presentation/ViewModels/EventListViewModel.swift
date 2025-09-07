import Foundation

// Esta clase maneja la lista de eventos del usuario
@MainActor
final class EventListViewModel: ObservableObject {
    
    // Variables que la pantalla puede ver y cambiar
    @Published var events: [Event] = []
    @Published var eventsState: LoadingState<[Event]> = .idle
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var currentUser: User?
    
    // Cosas que necesita para funcionar
    private let getEventsUseCase: GetEventsUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    
    // Variables calculadas
    var upcomingEvents: [Event] {
        events.filter { $0.isUpcoming }
    }
    
    var pastEvents: [Event] {
        events.filter { !$0.isUpcoming }
    }
    
    var hasEvents: Bool {
        !events.isEmpty
    }
    
    // Constructor
    init(getEventsUseCase: GetEventsUseCaseProtocol, authUseCase: AuthUseCaseProtocol, user: User) {
        self.getEventsUseCase = getEventsUseCase
        self.authUseCase = authUseCase
        self.currentUser = user
        
        // Cargar los eventos cuando se crea
        Task {
            await loadEvents()
        }
    }
    
    // Métodos que usa la pantalla
    
    // Carga todos los eventos del usuario
    func loadEvents() async {
        eventsState = .loading
        
        do {
            let userEvents = try await getEventsUseCase.getUserEvents()
            events = userEvents
            eventsState = .success(userEvents)
        } catch {
            eventsState = .failure(error)
            showError("Error al cargar eventos: \(error.localizedDescription)")
        }
    }
    
    // Recarga los eventos (cuando haces pull to refresh)
    func refreshEvents() async {
        await loadEvents()
    }
    
    // Cierra sesión del usuario
    func signOut() async {
        do {
            try await authUseCase.signOut()
            currentUser = nil
            events = []
            eventsState = .idle
        } catch {
            showError("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
    
    // Métodos internos
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}