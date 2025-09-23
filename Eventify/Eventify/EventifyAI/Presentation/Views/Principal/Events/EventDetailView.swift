import SwiftUI

// Pantalla que muestra el detalle completo de un evento y permite votar
struct EventDetailView: View {
    
    @State private var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(eventId: String) {
        self._viewModel = State(wrappedValue: EventDetailViewModel(eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            // Fondo púrpura como en las imágenes
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.08, green: 0.31, blue: 0.6), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.31, green: 0.27, blue: 0.58), location: 0.40),
                    Gradient.Stop(color: Color(red: 0.45, green: 0.22, blue: 0.57), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.02, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
            .ignoresSafeArea()
            
            if let event = viewModel.event {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header del evento
                        VStack(spacing: 16) {
                            // Icono grande del evento
                            RoundedRectangle(cornerRadius: 20)
                                .fill(getEventColor(for: event.title))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    getEventIcon(for: event.title)
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                            
                            Text(event.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Detalles en tarjetas
                        VStack(spacing: 16) {
                            EventDetailCard(
                                icon: "calendar",
                                title: "Fecha",
                                content: event.formattedDate
                            )
                            
                            EventDetailCard(
                                icon: "clock",
                                title: "Hora",
                                content: event.formattedTime
                            )
                            
                            EventDetailCard(
                                icon: "location.fill",
                                title: "Ubicación",
                                content: event.location
                            )
                            
                            EventDetailCard(
                                icon: "person.fill",
                                title: "Organizador",
                                content: event.organizerName
                            )
                            
                            if !event.description.isEmpty {
                                EventDetailCard(
                                    icon: "text.alignleft",
                                    title: "Descripción",
                                    content: event.description
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            } else if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Cargando evento...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("No se pudo cargar el evento")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Button("Reintentar") {
                        Task {
                            await viewModel.loadEventDetail()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadEventDetail()
        }
    }
    
    // Función para obtener color del evento
    private func getEventColor(for title: String) -> Color {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return .blue }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return .green }
        if lowercased.contains("picnic") { return .orange }
        if lowercased.contains("room") || lowercased.contains("escape") { return .yellow }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return .red }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return .purple }
        return .blue
    }
    
    // Función para obtener icono del evento
    private func getEventIcon(for title: String) -> Image {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return Image(systemName: "film") }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return Image(systemName: "tree") }
        if lowercased.contains("picnic") { return Image(systemName: "basket") }
        if lowercased.contains("room") || lowercased.contains("escape") { return Image(systemName: "key") }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return Image(systemName: "wineglass") }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return Image(systemName: "party.popper") }
        return Image(systemName: "calendar")
    }
}

// Nueva vista simplificada para las tarjetas de detalle
struct EventDetailCard: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            
            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}


#Preview {
    NavigationStack {
        EventDetailView(eventId: "preview-event-1")
    }
}