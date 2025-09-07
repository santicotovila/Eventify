import Foundation

// Define qué operaciones de login/registro puede hacer
protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() -> User?
}

// Esta clase maneja todo el tema de login con Firebase
// Es como un intermediario entre la app y Firebase
final class AuthRepository: AuthRepositoryProtocol {
    
    // Cosas que necesita para funcionar
    private let firebaseDataSource: FirebaseDataSourceProtocol
    
    // Constructor
    init(firebaseDataSource: FirebaseDataSourceProtocol) {
        self.firebaseDataSource = firebaseDataSource
    }
    
    // Métodos públicos
    
    // Hace login con Firebase
    func signIn(email: String, password: String) async throws -> User {
        return try await firebaseDataSource.signIn(email: email, password: password)
    }
    
    // Registra un usuario nuevo en Firebase
    func signUp(email: String, password: String) async throws -> User {
        return try await firebaseDataSource.signUp(email: email, password: password)
    }
    
    // Cierra sesión en Firebase
    func signOut() async throws {
        try await firebaseDataSource.signOut()
    }
    
    // Obtiene quién está logueado en Firebase
    func getCurrentUser() -> User? {
        return firebaseDataSource.getCurrentUser()
    }
}