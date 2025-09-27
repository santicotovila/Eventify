import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showingEditProfile: Bool = false
    var showingLogoutAlert: Bool = false
    
    // Datos del perfil del usuario
    var displayName: String = ""
    var userEmail: String = ""
    
    private let loginUseCase: LoginUseCaseProtocol
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        loadUserData()
    }
    
    
    func loadUserData() {
        guard let user = loginUseCase.getCurrentUser() else { return }
        
        displayName = user.displayName ?? user.name
        userEmail = user.email
    }
    
    
    func showEditProfile() {
        showingEditProfile = true
    }
    
    func saveProfile() async {
        isLoading = true
        errorMessage = nil
        
        // Simular guardado de datos
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        showingEditProfile = false
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await loginUseCase.signOut()
        } catch {
            errorMessage = "Error al cerrar sesión: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func showLogoutConfirmation() {
        showingLogoutAlert = true
    }
    
    // MARK: - Computed Properties
    
    var currentUser: UserModel? {
        return loginUseCase.getCurrentUser()
    }
    
    var userInitials: String {
        let components = displayName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
}


