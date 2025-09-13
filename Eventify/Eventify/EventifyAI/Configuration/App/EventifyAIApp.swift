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


import SwiftUI
import TipKit

@main
struct EventifyAIApp: App {
    
    @State private var isInitialized = false
    
    
    
    
    
    /*
     init() {
     Task {
     
     await setupTipKit()
     }
     }*/
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInitialized {
                    PrincipalView()
                    //      .environmentObject(appStateVM)
                } else {
                    SplashView(isInitialized: $isInitialized)
                }
            }/*
              .task {
              await initializeApp()
              }*/
        }
    }
    
    /*
     /// Configuración inicial de TipKit
     private func setupTipKit() async {
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
     */
    /*
     //TODO: - Teniendo un splash y launch deberia ser suficiente para cargarla talvez y asi no relentizamos el inicio de usuario, que opinas?
     
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
     }*/
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
