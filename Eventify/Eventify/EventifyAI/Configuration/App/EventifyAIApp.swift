//
//  EventifyAIApp.swift
//  EventifyAI
//
//  Created by Javier Gomez on 6/9/25.
//

import SwiftUI
import SwiftData
import Firebase

// Esta es la app principal de EventifyAI
// Configura Firebase y maneja si hay alguien logueado o no
@main
struct EventifyAIApp: App {
    
    // Aquí guardamos si hay alguien logueado
    @State private var currentUser: User?
    
    // Cuando la app arranca, configuramos Firebase
    init() {
        // Prepara Firebase para que funcione
        configureFirebase()
    }
    
    // Aquí va la ventana principal de la app
    var body: some Scene {
        WindowGroup {
            ContentView(
                currentUser: $currentUser,
                onUserSignedIn: { user in
                    currentUser = user
                },
                onUserSignedOut: {
                    currentUser = nil
                }
            )
            .modelContainer(SwiftDataManager.shared.container)
            .onAppear {
                // Cuando aparece la app, revisar si ya hay alguien logueado
                checkExistingSession()
            }
        }
    }
    
    // Métodos que usa la app internamente
    
    // Configura Firebase para que funcione con nuestros datos
    private func configureFirebase() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            fatalError("No se encontró GoogleService-Info.plist. Asegúrate de agregarlo al proyecto.")
        }
        
        FirebaseApp.configure()
        print("✅ Firebase configurado correctamente")
    }
    
    // Revisa si ya hay alguien logueado cuando la app arranca
    private func checkExistingSession() {
        let authUseCase = AppFactory.shared.makeAuthUseCase()
        currentUser = authUseCase.getCurrentUser()
        
        if let user = currentUser {
            print("✅ Sesión existente encontrada para: \(user.email)")
        } else {
            print("ℹ️ No hay sesión activa")
        }
    }
}

