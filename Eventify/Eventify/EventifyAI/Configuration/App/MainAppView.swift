import SwiftUI

/// Vista principal de la aplicación después del login
/// Contiene el TabView con las diferentes secciones
struct MainAppView: View {
    
    // MARK: - Properties
    let user: User
    let onSignOut: () -> Void
    
    // MARK: - Body
    var body: some View {
        TabView {
            // Events Tab
            EventListView(
                user: user,
                onSignOut: onSignOut
            )
            .tabItem {
                Image(systemName: "calendar")
                Text("Eventos")
            }
            
            // Create Event Tab
            CreateEventQuickView()
            .tabItem {
                Image(systemName: "plus.circle")
                Text("Crear")
            }
        }
        .accentColor(.blue)
    }
}

/// Vista rápida para crear eventos desde el tab
struct CreateEventQuickView: View {
    
    @State private var showingCreateEvent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    Text("Crear Nuevo Evento")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Organiza tu próximo evento de forma rápida y sencilla")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button("Empezar") {
                    showingCreateEvent = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.headline)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nuevo Evento")
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                onEventCreated: {
                    // El evento se creó exitosamente
                    showingCreateEvent = false
                }
            )
        }
    }
}

#Preview {
    MainAppView(
        user: User(id: "preview", email: "usuario@ejemplo.com"),
        onSignOut: {}
    )
}

#Preview("Create Event Quick View") {
    CreateEventQuickView()
}

