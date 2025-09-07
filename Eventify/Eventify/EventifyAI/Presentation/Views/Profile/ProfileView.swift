import SwiftUI

/// Vista de perfil del usuario con información y opciones
struct ProfileView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: EventListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSignOutAlert = false
    
    let onSignOut: () -> Void
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                // User Info Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentUser?.email ?? "Usuario")
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text("EventifyAI")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Statistics Section
                Section("Estadísticas") {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        
                        Text("Total de eventos")
                        
                        Spacer()
                        
                        Text("\(viewModel.events.count)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.green)
                            .frame(width: 25)
                        
                        Text("Eventos próximos")
                        
                        Spacer()
                        
                        Text("\(viewModel.upcomingEvents.count)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundColor(.gray)
                            .frame(width: 25)
                        
                        Text("Eventos pasados")
                        
                        Spacer()
                        
                        Text("\(viewModel.pastEvents.count)")
                            .fontWeight(.medium)
                    }
                }
                
                // App Info Section
                Section("Información") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        
                        Text("Versión")
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hammer")
                            .foregroundColor(.orange)
                            .frame(width: 25)
                        
                        Text("Build")
                        
                        Spacer()
                        
                        Text("MVP")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Actions Section
                Section {
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 25)
                            
                            Text("Cerrar Sesión")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert("Cerrar Sesión", isPresented: $showingSignOutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                Task {
                    await viewModel.signOut()
                    onSignOut()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?")
        }
    }
}

#Preview {
    ProfileView(
        viewModel: MockEventListViewModel(),
        onSignOut: {}
    )
}

// MARK: - Mock para Preview
@MainActor
final class MockEventListViewModel: ObservableObject {
    @Published var events: [Event] = [
        Event(
            title: "Cena de Cumpleaños",
            description: "Celebrar cumpleaños",
            creatorId: "user1",
            creatorEmail: "usuario@ejemplo.com",
            dateTime: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            location: "Restaurante"
        ),
        Event(
            title: "Reunión de Trabajo",
            description: "Reunión mensual",
            creatorId: "user1",
            creatorEmail: "usuario@ejemplo.com",
            dateTime: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            location: "Oficina"
        )
    ]
    @Published var eventsState: LoadingState<[Event]> = .idle
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var currentUser: User? = User(id: "preview", email: "usuario@ejemplo.com")
    
    var upcomingEvents: [Event] {
        events.filter { $0.isUpcoming }
    }
    
    var pastEvents: [Event] {
        events.filter { !$0.isUpcoming }
    }
    
    var hasEvents: Bool {
        !events.isEmpty
    }
    
    func loadEvents() async {}
    func refreshEvents() async {}
    func signOut() async {}
}