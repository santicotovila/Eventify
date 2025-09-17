import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppStateVM
    @State private var selectedTab = 0
    @State private var showCreateEvent = false
    @State private var showEventiBot = false
    @State private var previousTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EventsHomeView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Eventos")
                }
                .tag(0)
            
            // Tab vacía para Crear - solo activa el sheet
            Color.clear
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Crear")
                }
                .tag(1)
            
            // Tab vacía para EventiBot - solo activa el modal
            Color.clear
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("IA")
                }
                .tag(2)
            
            ProfileTabView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Perfil")
                }
                .tag(3)
        }
        .accentColor(.purple)
        .onChange(of: selectedTab) { oldValue, newTab in
            handleTabChange(newTab)
        }
        .sheet(isPresented: $showCreateEvent) {
            CreateEventView {
                // Callback cuando se crea evento
            }
        }
        .sheet(isPresented: $showEventiBot) {
            AnimatedEventiBotView()
        }
    }
    
    private func handleTabChange(_ newTab: Int) {
        switch newTab {
        case 1: // Tab Crear
            DispatchQueue.main.async {
                showCreateEvent = true
                selectedTab = previousTab
            }
        case 2: // Tab EventiBot
            DispatchQueue.main.async {
                showEventiBot = true
                selectedTab = previousTab
            }
        default:
            previousTab = newTab
        }
    }
}

struct EventsHomeView: View {
    
    @StateObject private var viewModel: EventsViewModel
    @EnvironmentObject var appState: AppStateVM
    @State private var showCreateEvent = false
    
    init() {
        let eventsRepository = DefaultEventsRepository()
        let loginRepository = DefaultLoginRepository()
        let eventsUseCase = EventsUseCase(repository: eventsRepository, loginRepository: loginRepository)
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        
        self._viewModel = StateObject(wrappedValue: EventsViewModel(eventsUseCase: eventsUseCase, loginUseCase: loginUseCase))
    }
    
    var body: some View {
        ZStack {
            // Fondo con degradado igual al diseño
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(1.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header minimalista como en la imagen
                HStack {
                    Text("Eventos")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Botón de logout como en la imagen
                    Button(action: {
                        Task {
                            await appState.signOut()
                        }
                    }) {
                        Image(systemName: "power")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Lista de eventos
                if viewModel.isLoading && viewModel.events.isEmpty {
                    LoaderView(message: "Cargando eventos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.events.isEmpty {
                    EmptyEventsHomeView {
                        showCreateEvent = true
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.events) { event in
                                NavigationLink(destination: EventDetailView(eventId: event.id)) {
                                    EventsRowView(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .refreshable {
                        await viewModel.refreshEvents()
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showCreateEvent) {
            CreateEventView {
                Task {
                    await viewModel.refreshEvents()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .task {
            await viewModel.loadEvents()
        }
    }
}

struct EventCard {
    let title: String
    let date: String
    let image: String
    let color: Color
}


// Vista vacía personalizada para HomeView
struct EmptyEventsHomeView: View {
    let onCreateEvent: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.purple.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("¡Bienvenido a Eventify!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Crea tu primer evento y comienza a organizar experiencias increíbles")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Crear mi primer evento") {
                onCreateEvent()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.purple)
        }
        .padding()
    }
}

// Nueva vista animada para EventiBot
struct AnimatedEventiBotView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Fondo con degradado
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(1.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo animado
                VStack(spacing: 20) {
                    Image("Logo-Eventify")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .scaleEffect(scale * pulseScale)
                        .rotationEffect(.degrees(rotation))
                        .opacity(opacity)
                        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                    
                    Text("EventifyAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(opacity)
                        .scaleEffect(scale)
                    
                    Text("Próximamente...")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(opacity)
                        .scaleEffect(scale)
                }
                
                Spacer()
                
                // Botón cerrar discreto
                Button(action: {
                    dismiss()
                }) {
                    Text("Cerrar")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .opacity(opacity)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Animación inicial de entrada
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Rotación continua
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Pulsación del logo
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
}

// Vista de Perfil mejorada
struct ProfileTabView: View {
    @EnvironmentObject var appState: AppStateVM
    
    var body: some View {
        ZStack {
            // Fondo con degradado
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 0) {
                    // Header del perfil
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(Color.purple.opacity(0.8))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(appState.userDisplayName.prefix(1)))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(appState.userDisplayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if let user = appState.currentUser {
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Opciones del perfil
                    VStack(spacing: 20) {
                        ProfileOptionRow(
                            icon: "person.circle",
                            title: "Editar Perfil",
                            action: {
                                // TODO: Implementar edición de perfil
                            }
                        )
                        
                        ProfileOptionRow(
                            icon: "bell",
                            title: "Notificaciones",
                            action: {
                                // TODO: Implementar configuración de notificaciones
                            }
                        )
                        
                        ProfileOptionRow(
                            icon: "gear",
                            title: "Configuración",
                            action: {
                                // TODO: Implementar configuración
                            }
                        )
                        
                        ProfileOptionRow(
                            icon: "info.circle",
                            title: "Acerca de EventifyAI",
                            action: {
                                // TODO: Implementar información de la app
                            }
                        )
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // Botón de logout
                        Button(action: {
                            Task {
                                await appState.signOut()
                            }
                        }) {
                            HStack {
                                Image(systemName: "power")
                                    .foregroundColor(.red)
                                Text("Cerrar Sesión")
                                    .foregroundColor(.red)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .disabled(appState.isLoading)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .navigationTitle("Perfil")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
}


#Preview {
    let loginRepository = DefaultLoginRepository()
    let loginUseCase = LoginUseCase(loginRepository: loginRepository)
    let appState = AppStateVM(loginUseCase: loginUseCase)
    
    return HomeView()
        .environmentObject(appState)
}
