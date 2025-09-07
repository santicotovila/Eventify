import Foundation

// Esta clase maneja el detalle de un evento y los votos
@MainActor
final class EventDetailViewModel: ObservableObject {
    
    // Variables que la pantalla puede ver y cambiar
    @Published var event: Event?
    @Published var attendances: [Attendance] = []
    @Published var userAttendance: Attendance?
    @Published var detailState: LoadingState<Event> = .idle
    @Published var attendanceState: LoadingState<[Attendance]> = .idle
    @Published var voteState: LoadingState<Attendance> = .idle
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // Cosas que necesita para funcionar
    private let getEventsUseCase: GetEventsUseCaseProtocol
    private let voteAttendanceUseCase: VoteAttendanceUseCaseProtocol
    private let authUseCase: AuthUseCaseProtocol
    
    // Variables internas
    private let eventId: String
    
    // Variables calculadas
    var currentUser: User? {
        authUseCase.getCurrentUser()
    }
    
    var isEventCreator: Bool {
        guard let event = event, let currentUser = currentUser else { return false }
        return event.creatorId == currentUser.id
    }
    
    var yesCount: Int {
        attendances.filter { $0.status == .yes }.count
    }
    
    var noCount: Int {
        attendances.filter { $0.status == .no }.count
    }
    
    var maybeCount: Int {
        attendances.filter { $0.status == .maybe }.count
    }
    
    var attendancesSummary: String {
        let total = attendances.count
        if total == 0 {
            return "Sin respuestas aún"
        }
        return "Sí: \(yesCount) • No: \(noCount) • Tal vez: \(maybeCount)"
    }
    
    // Constructor
    init(eventId: String, getEventsUseCase: GetEventsUseCaseProtocol, voteAttendanceUseCase: VoteAttendanceUseCaseProtocol, authUseCase: AuthUseCaseProtocol) {
        self.eventId = eventId
        self.getEventsUseCase = getEventsUseCase
        self.voteAttendanceUseCase = voteAttendanceUseCase
        self.authUseCase = authUseCase
        
        // Cargar toda la info cuando se crea
        Task {
            await loadEventDetail()
            await loadAttendances()
        }
    }
    
    // Métodos que usa la pantalla
    
    // Carga la info del evento
    func loadEventDetail() async {
        detailState = .loading
        
        do {
            if let loadedEvent = try await getEventsUseCase.getEventById(eventId) {
                event = loadedEvent
                detailState = .success(loadedEvent)
            } else {
                detailState = .failure(EventError.eventNotFound)
                showError("Evento no encontrado")
            }
        } catch {
            detailState = .failure(error)
            showError("Error al cargar evento: \(error.localizedDescription)")
        }
    }
    
    // Carga todos los votos del evento
    func loadAttendances() async {
        attendanceState = .loading
        
        do {
            let eventAttendances = try await voteAttendanceUseCase.getAttendances(for: eventId)
            attendances = eventAttendances
            attendanceState = .success(eventAttendances)
            
            // Buscar el voto de la persona logueada
            userAttendance = try await voteAttendanceUseCase.getUserAttendance(eventId: eventId)
            
        } catch {
            attendanceState = .failure(error)
            showError("Error al cargar asistencias: \(error.localizedDescription)")
        }
    }
    
    // Guarda el voto de la persona (sí, no, tal vez)
    func vote(status: AttendanceStatus) async {
        voteState = .loading
        
        do {
            let attendance = try await voteAttendanceUseCase.vote(eventId: eventId, status: status)
            voteState = .success(attendance)
            userAttendance = attendance
            
            // Recargar los votos para mostrar el cambio
            await loadAttendances()
            
        } catch {
            voteState = .failure(error)
            showError("Error al votar: \(error.localizedDescription)")
        }
    }
    
    // Recarga todo (evento y votos)
    func refreshData() async {
        await loadEventDetail()
        await loadAttendances()
    }
    
    // Métodos internos
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}