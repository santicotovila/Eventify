//
//  AppStateVM.swift
//  EventifyAI
//
//  Created by Javier Gómez on 9/9/25.
//

import Foundation
import Combine

@MainActor
@Observable
final class AppStateVM {
    
    var isUserAuthenticated: Bool = false
    var currentUser: UserModel?
    var selectedTab: Int = 0
    var showAlert: Bool = false
    var alertMessage: String = ""
    var isLoading: Bool = false
    
    @ObservationIgnored
    private let loginUseCase: LoginUseCaseProtocol
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        // Al iniciar, comprobamos si ya hay una sesión guardada.
        self.isUserAuthenticated = loginUseCase.isUserAuthenticated()
        self.currentUser = loginUseCase.getCurrentUser()
        setupSubscribers()
    }
    
    // Comprueba de nuevo el estado de autenticación.
    func checkAuthenticationState() {
        self.isUserAuthenticated = loginUseCase.isUserAuthenticated()
        self.currentUser = loginUseCase.getCurrentUser()
    }
   
    func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
    
    func dismissAlert() {
        self.showAlert = false
        self.alertMessage = ""
    }
    
    //  nombre de usuario
    var userDisplayName: String {
        return currentUser?.displayName ?? "Usuario"
    }
    
    
    //  cerrar sesión
    func signOut() async {
        isLoading = true
        
        do {
            try await loginUseCase.signOut()
            // El estado se actualiza automáticamente por las notificaciones
        } catch {
            showAlert(message: "Error al cerrar sesión: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Suscripcion a Notificaciones
    // Escucha notificaciones globales para mantener el estado actualizado.
    private func setupSubscribers() {
        // Se suscribe a la notificación de login exitoso.
        NotificationCenter.default.userDidSignInPublisher
            .receive(on: DispatchQueue.main) // Actualiza en el hilo principal.
            .sink { [weak self] user in // Cuando llega la notificación, ejecuta esto.
                self?.isUserAuthenticated = true
                self?.currentUser = user
            }
            .store(in: &cancellables) // Guarda la suscripción para mantenerla viva.
        
        // Se suscribe a la notificación de logout.
        NotificationCenter.default.userDidSignOutPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_: Void) in
                self?.isUserAuthenticated = false
                self?.currentUser = nil
            }
            .store(in: &cancellables)
    }
}
