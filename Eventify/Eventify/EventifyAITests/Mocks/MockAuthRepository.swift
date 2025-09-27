import Foundation
@testable import EventifyAI

/// Mock del repositorio de autenticación para tests
final class MockAuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Test Properties
    var signInCalled = false
    var signUpCalled = false
    var signOutCalled = false
    
    // MARK: - Configurable Results
    var signInResult: User?
    var signUpResult: User?
    var currentUser: User?
    var shouldThrowError = false
    var errorToThrow: Error = AuthError.unknownAuthError
    
    
    func signIn(email: String, password: String) async throws -> User {
        signInCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let result = signInResult else {
            throw AuthError.userNotFound
        }
        
        return result
    }
    
    func signUp(email: String, password: String) async throws -> User {
        signUpCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let result = signUpResult else {
            throw AuthError.unknownAuthError
        }
        
        return result
    }
    
    func signOut() async throws {
        signOutCalled = true
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        currentUser = nil
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
}