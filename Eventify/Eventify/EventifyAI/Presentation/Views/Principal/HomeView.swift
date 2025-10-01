//
//  HomeView.swift
//  EventifyAI
//
//  Created by Javier Gómez on 11/9/25.
//

import SwiftUI

// Vista principal de la app - navegación con NavigationStack (iOS 16+)
struct HomeView: View {
    @Environment(AppStateVM.self) var appState: AppStateVM
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Contenido principal: lista de eventos
                EventsListView()
                
                // Tab bar personalizada en lugar de TabView nativa
                CustomTabBar()
            }
        }
    }
}

// Tab bar personalizada con NavigationLink para navegación
struct CustomTabBar: View {
    var body: some View {
        HStack {
            // Navegación a lista de amigos
            NavigationLink(destination: FriendsListView()) {
                CustomTabButton(icon: "person.2.fill", title: "Amigos")
            }
            
            Spacer()
            
            // Navegación a crear evento
            NavigationLink(destination: CreateEventView()) {
                CustomTabButton(icon: "plus.circle", title: "Crear")
            }
            
            Spacer()
            
            // Navegación a IA (pendiente de implementar)
            NavigationLink(destination: AnimatedEventiBotView()) {
                CustomTabButton(icon: "brain.head.profile", title: "IA")
            }
            
            Spacer()
            
            // Navegación a perfil 
            NavigationLink(destination: ProfileView(loginUseCase: LoginUseCase(loginRepository: DefaultLoginRepository()))) {
                CustomTabButton(icon: "person.circle", title: "Perfil")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.08, green: 0.31, blue: 0.6), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.31, green: 0.27, blue: 0.58), location: 0.40),
                    Gradient.Stop(color: Color(red: 0.45, green: 0.22, blue: 0.57), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.02, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
        )
    }
}

// Componente reutilizable para botones de tab - SF Symbols + texto
struct CustomTabButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}

// Vista placeholder para EventiBot con animaciones SwiftUI
struct AnimatedEventiBotView: View {
    // @State para animaciones - valores que cambian durante la animación
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
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // Función para iniciar animaciones con diferentes tipos de curvas
    private func startAnimations() {
        // Animación de entrada con easing
        withAnimation(.easeOut(duration: 0.8)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Rotación infinita sin parar
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Pulsación que se repite ida y vuelta
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
}


// Preview con setup completo de dependencias para desarrollo
#Preview {
    let loginRepository = DefaultLoginRepository()
    let loginUseCase = LoginUseCase(loginRepository: loginRepository)
    let appState = AppStateVM(loginUseCase: loginUseCase)
    
    HomeView()
        .environment(appState)
}

