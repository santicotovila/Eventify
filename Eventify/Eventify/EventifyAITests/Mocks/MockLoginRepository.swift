import Foundation
@testable import EventifyAI

final class MockLoginRepository: LoginRepositoryProtocol {
    
    // MARK: - Test Control Properties
    var signInCalled = false
    var signUpCalled = false
    var signOutCalled = false
    var getCurrentUserCalled = false
    var refreshTokenCalled = false
    var saveUserCalled = false
    
    // MARK: - Configurable Results
    var signInResult: Result<UserModel, Error> = .failure(AuthError.invalidCredentials)
    var signUpResult: Result<UserModel, Error> = .failure(AuthError.emailAlreadyInUse)
    var signOutResult: Result<Void, Error> = .success(())
    var currentUser: UserModel?
    var userToken: String?
    var refreshTokenResult: Result<String, Error> = .success("mock-refreshed-token")
    var saveUserResult: Result<Void, Error> = .success(())
    
    // MARK: - Protocol Implementation
    
    func signIn(email: String, password: String) async throws -> UserModel {
        signInCalled = true
        
        switch signInResult {
        case .success(let user):
            currentUser = user
            return user
        case .failure(let error):
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        signUpCalled = true
        
        switch signUpResult {
        case .success(let user):
            currentUser = user
            return user
        case .failure(let error):
            throw error
        }
    }
    
    func signOut() async throws {
        signOutCalled = true
        
        switch signOutResult {
        case .success:
            currentUser = nil
            userToken = nil
        case .failure(let error):
            throw error
        }
    }
    
    func getCurrentUser() -> UserModel? {
        getCurrentUserCalled = true
        return currentUser
    }
    
    func refreshToken() async throws -> String {
        refreshTokenCalled = true
        
        switch refreshTokenResult {
        case .success(let token):
            userToken = token
            return token
        case .failure(let error):
            throw error
        }
    }
    
    func isUserAuthenticated() -> Bool {
        return getCurrentUser() != nil
    }
    
    func getUserToken() -> String? {
        return userToken
    }
    
    func saveUser(_ user: UserModel) throws {
        saveUserCalled = true
        
        switch saveUserResult {
        case .success:
            currentUser = user
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Test Helper Methods
    
    func reset() {
        signInCalled = false
        signUpCalled = false
        signOutCalled = false
        getCurrentUserCalled = false
        refreshTokenCalled = false
        saveUserCalled = false
        
        currentUser = nil
        userToken = nil
        
        signInResult = .failure(AuthError.invalidCredentials)
        signUpResult = .failure(AuthError.emailAlreadyInUse)
        signOutResult = .success(())
        refreshTokenResult = .success("mock-refreshed-token")
        saveUserResult = .success(())
    }
    
    func setSuccessfulSignIn(user: UserModel) {
        signInResult = .success(user)
    }
    
    func setSuccessfulSignUp(user: UserModel) {
        signUpResult = .success(user)
    }
    
    func setFailedSignIn(error: Error) {
        signInResult = .failure(error)
    }
    
    func setFailedSignUp(error: Error) {
        signUpResult = .failure(error)
    }
    
    func setAuthenticatedUser(_ user: UserModel, token: String? = nil) {
        currentUser = user
        userToken = token ?? "mock-token"
    }
}