import Foundation

@MainActor
@Observable
final class ProfileViewModel {
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var showingEditProfile: Bool = false
    var showingLogoutAlert: Bool = false
    
    // Datos editables del perfil
    var displayName: String = ""
    var phoneNumber: String = ""
    var birthDate: Date = Date()
    
    private let loginUseCase: LoginUseCaseProtocol
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        loadUserData()
    }
    
    
    func loadUserData() {
        guard let user = loginUseCase.getCurrentUser() else { return }
        
        displayName = user.displayName ?? "Anonymous"
        phoneNumber = "+3467480303"
        birthDate = DateFormatter.dateFromString("27.05.1995") ?? Date()
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
    
    var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: birthDate)
    }
}

// MARK: - Extensions

private extension DateFormatter {
    static func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: dateString)
    }
}

