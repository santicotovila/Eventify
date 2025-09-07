import SwiftUI

// Pantalla que muestra todos los eventos del usuario
struct EventListView: View {
    
    // Variables que necesita
    @StateObject private var viewModel: EventListViewModel
    @State private var showingCreateEvent = false
    @State private var showingProfile = false
    
    let user: User
    let onSignOut: () -> Void
    
    // Constructor
    init(user: User, onSignOut: @escaping () -> Void) {
        self.user = user
        self.onSignOut = onSignOut
        self._viewModel = StateObject(wrappedValue: EventListViewModel(
            getEventsUseCase: AppFactory.shared.makeGetEventsUseCase(),
            authUseCase: AppFactory.shared.makeAuthUseCase(),
            user: user
        ))
    }
    
    // Lo que se ve en la pantalla
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.eventsState.isLoading && viewModel.events.isEmpty {
                    // Cuando está cargando
                    VStack {
                        ProgressView()
                        Text("Cargando eventos...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                } else if viewModel.events.isEmpty {
                    // Cuando no hay eventos
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No tienes eventos")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Crea tu primer evento para empezar a organizar")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Crear Evento") {
                            showingCreateEvent = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    // Events list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Upcoming Events Section
                            if !viewModel.upcomingEvents.isEmpty {
                                EventSection(
                                    title: "Próximos Eventos",
                                    events: viewModel.upcomingEvents,
                                    icon: "calendar"
                                )
                            }
                            
                            // Past Events Section
                            if !viewModel.pastEvents.isEmpty {
                                EventSection(
                                    title: "Eventos Pasados",
                                    events: viewModel.pastEvents,
                                    icon: "calendar.badge.checkmark"
                                )
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshEvents()
                    }
                }
            }
            .navigationTitle("Mis Eventos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateEvent = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                onEventCreated: {
                    Task {
                        await viewModel.refreshEvents()
                    }
                    showingCreateEvent = false
                }
            )
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(
                viewModel: viewModel,
                onSignOut: {
                    onSignOut()
                    showingProfile = false
                }
            )
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

/// Sección de eventos con título e icono
struct EventSection: View {
    let title: String
    let events: [Event]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(
                        eventId: event.id
                    )) {
                        EventRowView(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

/// Vista de fila para mostrar cada evento en la lista
struct EventRowView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(event.formattedTime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(event.isUpcoming ? .blue : .secondary)
                }
            }
            
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    EventListView(
        user: User(id: "preview", email: "usuario@ejemplo.com"),
        onSignOut: {}
    )
}

// MARK: - Mocks para Preview
final class MockGetEventsUseCase: GetEventsUseCaseProtocol {
    func getUserEvents() async throws -> [Event] {
        return [
            Event(
                title: "Cena de Cumpleaños",
                description: "Celebremos el cumpleaños de Ana en su restaurante favorito",
                creatorId: "user1",
                creatorEmail: "ana@ejemplo.com",
                dateTime: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                location: "Restaurante El Buen Gusto"
            ),
            Event(
                title: "Reunión de Trabajo",
                description: "Revisión mensual del proyecto",
                creatorId: "user1", 
                creatorEmail: "usuario@ejemplo.com",
                dateTime: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                location: "Oficina Central"
            )
        ]
    }
    
    func getEventById(_ id: String) async throws -> Event? {
        return nil
    }
    
    func getUpcomingEvents() async throws -> [Event] {
        return []
    }
}

final class MockAuthUseCaseForPreview: AuthUseCaseProtocol {
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