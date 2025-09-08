import Foundation

@MainActor
final class EventDetailViewModel: ObservableObject {
    
    @Published var event: EventModel?
    @Published var userAttendance: AttendanceModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isShowingAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var voteState: Bool = false
    
    private let eventId: String
    private let eventsUseCase: EventsUseCaseProtocol
    private let attendanceUseCase: AttendanceUseCaseProtocol
    private let loginUseCase: LoginUseCaseProtocol
    
    init(eventId: String, eventsUseCase: EventsUseCaseProtocol, attendanceUseCase: AttendanceUseCaseProtocol, loginUseCase: LoginUseCaseProtocol) {
        self.eventId = eventId
        self.eventsUseCase = eventsUseCase
        self.attendanceUseCase = attendanceUseCase
        self.loginUseCase = loginUseCase
    }
    
    func loadEventDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let updatedEvent = try await eventsUseCase.getEventById(eventId) else {
                errorMessage = "No se pudo encontrar el evento."
                isLoading = false
                return
            }
            self.event = updatedEvent
            
            // Cargar asistencia del usuario si está autenticado
            if let currentUser = loginUseCase.getCurrentUser() {
                userAttendance = try await attendanceUseCase.getUserAttendance(userId: currentUser.id, eventId: eventId)
            }
        } catch {
            errorMessage = "Error al cargar los detalles del evento: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func vote(status: AttendanceStatus) async {
        guard let currentUser = loginUseCase.getCurrentUser() else {
            showAlert(message: "Debes iniciar sesión para votar")
            return
        }
        
        voteState = true
        
        do {
            let attendance = try await attendanceUseCase.saveAttendance(
                userId: currentUser.id,
                eventId: eventId,
                status: status,
                userName: currentUser.displayName ?? "Usuario"
            )
            userAttendance = attendance
        } catch {
            showAlert(message: "Error al votar: \(error.localizedDescription)")
        }
        
        voteState = false
    }
    
    func refreshData() async {
        await loadEventDetail()
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        isShowingAlert = true
    }
}
