import SwiftUI

struct HomeView: View {
    @Environment(AppStateVM.self) var appState: AppStateVM
    @State private var selectedTab = 0
    @State private var showCreateEvent = false
    @State private var showEventiBot = false
    @State private var previousTab = 0
    
    var body: some View {
        ZStack {
            // Fondo púrpura 
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
            
            TabView(selection: $selectedTab) {
            EventsHomeView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Eventos")
                }
                .tag(0)
            
            // Tab vacía para Crear
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
            
            ProfileView(loginUseCase: LoginUseCase(loginRepository: DefaultLoginRepository()))
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Perfil")
                }
                .tag(3)
        }
        .accentColor(.gray)
        .onChange(of: selectedTab) { oldValue, newTab in
            handleTabChange(newTab)
        }
        .sheet(isPresented: $showCreateEvent) {
            CreateEventView {
                // vuelve cuando se crea evento
            }
        }
        .sheet(isPresented: $showEventiBot) {
            AnimatedEventiBotView()
        }
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
    var body: some View {
        EventsListView()
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
                stops: [
                    Gradient.Stop(color: Color(red: 0.08, green: 0.31, blue: 0.6), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.31, green: 0.27, blue: 0.58), location: 0.40),
                    Gradient.Stop(color: Color(red: 0.45, green: 0.22, blue: 0.57), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.02, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo animado
                VStack(spacing: 20) {
                    Image("Logo-Eventify")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
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
                
                // Botón cerrar
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

// Vista de Perfil
struct ProfileTabView: View {
    @Environment(AppStateVM.self) var appState: AppStateVM
    
    var body: some View {
        ZStack {
            // Fondo púrpura
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Perfil")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        
                    
                    Spacer()
                }
                .padding(.horizontal)
           
                
                Spacer()
                
                // Tarjeta blanca central con avatar centrado arriba
                VStack(spacing: 0) {
                    // Avatar centrado en la parte superior
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .fill(Color.purple.opacity(0.8))
                                .frame(width: 90, height: 90)
                                .overlay(
                                    Text(String(appState.userDisplayName.prefix(1)))
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        )
                        .padding(.top, 20)
                    
                    // Información del usuario centrada
                    VStack(spacing: 12) {
                        Text(appState.userDisplayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        if let user = appState.currentUser {
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Información adicional
                        VStack(spacing: 8) {
                            Text("+34 876863503")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Text("07.06.1995")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
                .frame(width: 328, height: 368, alignment: .topLeading)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                    RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                    .padding(.top, 24)
                    .padding(.horizontal, 30)
                
               
                Button(action: {
                    // TODO: Implementar edición de datos
                }) {
                    Text("Modificar datos personales")
                    .font(
                    Font.custom("SF Pro Rounded", size: 20)
                    .weight(.semibold)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .frame(width: 295, alignment: .center)
                    .background(Color(red: 0.57, green: 0.47, blue: 0.7))
                        .background(ConstantsApp.Colors.gris.opacity(0.05))
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 15)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
                
                // Botón de cerrar sesión en la parte inferior
                Button(action: {
                    Task {
                        await appState.signOut()
                    }
                }) {
                    HStack {
                        Text("Cerrar Sesión")
                            .font(
                            Font.custom("SF Pro Rounded", size: 20)
                            .weight(.semibold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        Image(systemName: "power")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 40)
                .disabled(appState.isLoading)
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
    
    HomeView()
        .environment(appState)
}
