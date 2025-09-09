/*
 * EventifyAIApp.swift
 * EventifyAI
 *
 * Aplicación principal de EventifyAI - Sistema de organización de eventos con IA
 * Arquitectura: Clean Architecture + MVVM + @Observable
 * 
 * Desarrollado por: Javier Gómez
 * Fecha: 6 Septiembre 2025
 * Versión: 1.0.0
 *
 * Descripción:
 * App principal que maneja el ciclo de vida de la aplicación,
 * configuración inicial, dependencias y navegación de alto nivel.
 * 
 * Funcionalidades principales:
 * - Gestión de sesiones de usuario
 * - Configuración de dependencias
 * - Navegación entre autenticación y app principal
 * - Manejo de estado global de la aplicación
 */

import SwiftUI
import TipKit

@main
struct EventifyAIApp: App {
    
    @State private var appStateVM: AppStateVM
    @State private var isInitialized = false
    
    init() {
        // Inicializar AppState con inyección directa
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        self._appStateVM = State(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
        
        // Configurar TipKit
        setupTipKit()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInitialized {
                    RootView()
                        .environmentObject(appStateVM)
                } else {
                    SplashView()
                }
            }
            .task {
                await initializeApp()
            }
        }
    }
    
    
    /// Configuración inicial de TipKit
    private func setupTipKit() {
        do {
            try Tips.resetDatastore()
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        } catch {
            // Silently handle error
        }
    }
    
    /// Inicialización asíncrona de la aplicación
    private func initializeApp() async {
        // Simular tiempo de carga inicial
        try? await Task.sleep(for: .milliseconds(1500))
        
        // Verificar estado de autenticación
        appStateVM.checkAuthenticationState()
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.8)) {
                isInitialized = true
            }
        }
    }
}

private struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                
                Text("EventifyAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Organizando eventos inteligentes")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

extension EventifyAIApp {
    
    /// Información de la aplicación
    static let appInfo = AppInfo(
        name: "EventifyAI",
        version: "1.0.0",
        build: "MVP",
        developer: "Javier Gómez",
        description: "Sistema inteligente de organización de eventos"
    )
}

struct AppInfo {
    let name: String
    let version: String
    let build: String
    let developer: String
    let description: String
}