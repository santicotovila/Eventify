import SwiftUI

// Pantalla que muestra el detalle completo de un evento y permite votar
struct EventDetailView: View {
    
    // Variables que necesita
    @StateObject private var viewModel: EventDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Constructor
    init(eventId: String) {
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(
            eventId: eventId,
            getEventsUseCase: AppFactory.shared.makeGetEventsUseCase(),
            voteAttendanceUseCase: AppFactory.shared.makeVoteAttendanceUseCase(),
            authUseCase: AppFactory.shared.makeAuthUseCase()
        ))
    }
    
    // Lo que se ve en la pantalla
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let event = viewModel.event {
                    // Título del evento
                    EventHeaderView(event: event)
                    
                    // Detalles del evento
                    EventDetailsView(event: event)
                    
                    // Sección para votar
                    AttendanceVotingView(
                        userAttendance: viewModel.userAttendance,
                        isLoading: viewModel.voteState.isLoading,
                        onVote: { status in
                            Task {
                                await viewModel.vote(status: status)
                            }
                        }
                    )
                    
                    // Resumen de votos
                    AttendanceSummaryView(
                        attendances: viewModel.attendances,
                        isLoading: viewModel.attendanceState.isLoading,
                        summary: viewModel.attendancesSummary
                    )
                    
                } else if viewModel.detailState.isLoading {
                    // Cuando está cargando
                    VStack {
                        ProgressView()
                        Text("Cargando evento...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Error State
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("No se pudo cargar el evento")
                            .font(.headline)
                        
                        Button("Reintentar") {
                            Task {
                                await viewModel.loadEventDetail()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refreshData()
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

/// Header del evento con título y fecha principal
struct EventHeaderView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            
            HStack {
                Label(event.formattedDate, systemImage: "calendar")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(event.formattedTime)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            if event.isUpcoming {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.green)
                    Text("Próximo evento")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

/// Detalles completos del evento
struct EventDetailsView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Location
            DetailRow(
                icon: "location.fill",
                title: "Ubicación",
                content: event.location,
                iconColor: .red
            )
            
            // Description
            DetailRow(
                icon: "text.alignleft",
                title: "Descripción",
                content: event.description,
                iconColor: .blue
            )
            
            // Creator
            DetailRow(
                icon: "person.fill",
                title: "Organizador",
                content: event.creatorEmail,
                iconColor: .purple
            )
            
            // Created date
            DetailRow(
                icon: "calendar.badge.plus",
                title: "Creado",
                content: DateFormatter.dateTimeFormatter.string(from: event.createdAt),
                iconColor: .gray
            )
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

/// Componente reutilizable para mostrar detalles con icono
struct DetailRow: View {
    let icon: String
    let title: String
    let content: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

/// Vista para votar asistencia al evento
struct AttendanceVotingView: View {
    let userAttendance: Attendance?
    let isLoading: Bool
    let onVote: (AttendanceStatus) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu Asistencia")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let attendance = userAttendance {
                Text("Ya has respondido: \(attendance.status.displayText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            
            HStack(spacing: 12) {
                ForEach(AttendanceStatus.allCases, id: \.self) { status in
                    VoteButton(
                        status: status,
                        isSelected: userAttendance?.status == status,
                        isLoading: isLoading,
                        onTap: { onVote(status) }
                    )
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

/// Botón individual para votar
struct VoteButton: View {
    let status: AttendanceStatus
    let isSelected: Bool
    let isLoading: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : statusColor)
                
                Text(status.displayText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : statusColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isSelected ? statusColor : statusColor.opacity(0.1))
            .cornerRadius(12)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: isSelected ? .white : statusColor))
                        .scaleEffect(0.8)
                }
            }
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var iconName: String {
        switch status {
        case .yes:
            return "checkmark.circle.fill"
        case .no:
            return "xmark.circle.fill"
        case .maybe:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .yes:
            return .green
        case .no:
            return .red
        case .maybe:
            return .orange
        }
    }
}

/// Resumen de asistencias del evento
struct AttendanceSummaryView: View {
    let attendances: [Attendance]
    let isLoading: Bool
    let summary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen de Asistencias")
                .font(.headline)
                .fontWeight(.semibold)
            
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Cargando asistencias...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !attendances.isEmpty {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(attendances) { attendance in
                            AttendanceRowView(attendance: attendance)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

/// Fila individual de asistencia
struct AttendanceRowView: View {
    let attendance: Attendance
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(statusColor)
                .frame(width: 20)
            
            Text(attendance.userEmail)
                .font(.subheadline)
            
            Spacer()
            
            Text(attendance.status.displayText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var iconName: String {
        switch attendance.status {
        case .yes:
            return "checkmark.circle.fill"
        case .no:
            return "xmark.circle.fill"
        case .maybe:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch attendance.status {
        case .yes:
            return .green
        case .no:
            return .red
        case .maybe:
            return .orange
        }
    }
}

#Preview {
    NavigationView {
        EventDetailView(
            eventId: "preview"
        )
    }
}

// MARK: - Mocks para Preview
final class MockGetEventsUseCaseDetail: GetEventsUseCaseProtocol {
    func getUserEvents() async throws -> [Event] { return [] }
    
    func getEventById(_ id: String) async throws -> Event? {
        return Event(
            title: "Cena de Cumpleaños de Ana",
            description: "Celebremos el cumpleaños de Ana en su restaurante favorito. Será una noche especial con buena comida y mejor compañía.",
            creatorId: "user1",
            creatorEmail: "ana@ejemplo.com",
            dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            location: "Restaurante El Buen Gusto, Centro de la Ciudad"
        )
    }
    
    func getUpcomingEvents() async throws -> [Event] { return [] }
}

final class MockVoteAttendanceUseCase: VoteAttendanceUseCaseProtocol {
    func vote(eventId: String, status: AttendanceStatus) async throws -> Attendance {
        return Attendance(eventId: eventId, userId: "preview", userEmail: "usuario@ejemplo.com", status: status)
    }
    
    func getAttendances(for eventId: String) async throws -> [Attendance] {
        return [
            Attendance(eventId: eventId, userId: "user1", userEmail: "juan@ejemplo.com", status: .yes),
            Attendance(eventId: eventId, userId: "user2", userEmail: "maria@ejemplo.com", status: .maybe),
            Attendance(eventId: eventId, userId: "user3", userEmail: "pedro@ejemplo.com", status: .no)
        ]
    }
    
    func getUserAttendance(eventId: String) async throws -> Attendance? {
        return Attendance(eventId: eventId, userId: "preview", userEmail: "usuario@ejemplo.com", status: .yes)
    }
}

final class MockAuthUseCaseDetail: AuthUseCaseProtocol {
    func signIn(email: String, password: String) async throws -> User {
        return User(id: "preview", email: email)
    }
    
    func signUp(email: String, password: String) async throws -> User {
        return User(id: "preview", email: email)
    }
    
    func signOut() async throws {}
    
    func getCurrentUser() -> User? {
        return User(id: "preview", email: "usuario@ejemplo.com")
    }
    
    func isUserSignedIn() -> Bool {
        return true
    }
}