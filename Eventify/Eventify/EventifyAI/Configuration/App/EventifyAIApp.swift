/*
 * EventifyAIApp.swift
 * EventifyAI
 */

import SwiftUI
import SwiftData
import TipKit

@main
struct EventifyAIApp: App {
    
    @State private var isInitialized = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isInitialized {
                    RootView()
                } else {
                    SplashView(isInitialized: $isInitialized)
                }
            }
        }
        .modelContainer(for: [EventDataModel.self])
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
