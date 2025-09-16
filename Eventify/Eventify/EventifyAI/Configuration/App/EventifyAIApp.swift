/*
 * EventifyAIApp.swift
 * EventifyAI
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
                    SplashView(isInitialized: $isInitialized)
                }
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
    
}

