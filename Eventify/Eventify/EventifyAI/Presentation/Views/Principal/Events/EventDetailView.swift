import SwiftUI

// Pantalla que muestra el detalle completo de un evento y permite votar
struct EventDetailView: View {
    
    // Variables que necesita
    @State private var viewModel: EventDetailViewModel
    
    // Constructor
    init(eventId: String) {
        self._viewModel = State(wrappedValue: EventDetailViewModel(
            eventId: eventId,
            eventsUseCase: AppFactory.shared.makeEventsUseCase(),
            attendanceUseCase: AppFactory.shared.makeAttendanceUseCase(),
            loginUseCase: AppFactory.shared.makeLoginUseCase()
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
                        isLoading: viewModel.voteState,
                        onVote: { status in
                            Task {
                                await viewModel.vote(status: status)
                            }
                        }
                    )
                    
                    
                } else if viewModel.isLoading {
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
        .alert("Error", isPresented: $viewModel.isShowingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

/// Header del evento con título y fecha principal
struct EventHeaderView: View {
    let event: EventModel
    
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
    let event: EventModel
    
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
                content: event.organizerName,
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
    let userAttendance: AttendanceModel?
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
        case .going:
            return "checkmark.circle.fill"
        case .notGoing:
            return "xmark.circle.fill"
        case .maybe:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .going:
            return .green
        case .notGoing:
            return .red
        case .maybe:
            return .orange
        }
    }
}

/// Resumen de asistencias del evento
struct AttendanceSummaryView: View {
    let attendances: [AttendanceModel]
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
    let attendance: AttendanceModel
    
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
        case .going:
            return "checkmark.circle.fill"
        case .notGoing:
            return "xmark.circle.fill"
        case .maybe:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch attendance.status {
        case .going:
            return .green
        case .notGoing:
            return .red
        case .maybe:
            return .orange
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(eventId: "preview")
    }
}