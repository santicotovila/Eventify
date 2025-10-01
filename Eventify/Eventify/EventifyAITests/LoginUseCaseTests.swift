import XCTest
@testable import EventifyAI

final class LoginUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: LoginUseCase!
    private var mockRepository: MockLoginRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockLoginRepository()
        sut = LoginUseCase(loginRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Sign In Tests
    
    func testSignIn_WithValidCredentials_ShouldReturnUser() async throws {
        // Given
        let email = "test@example.com"
        let password = "validpassword"
        let expectedUser = UserModel(id: "123", email: email, displayName: "Test User")
        
        mockRepository.setSuccessfulSignIn(user: expectedUser)
        
        // When
        let result = try await sut.signIn(email: email, password: password)
        
        // Then
        XCTAssertTrue(mockRepository.signInCalled)
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
        XCTAssertEqual(result.displayName, expectedUser.displayName)
    }
    
    func testSignIn_WithEmptyEmail_ShouldThrowError() async {
        // Given
        let email = ""
        let password = "validpassword"
        
        // When & Then
        do {
            _ = try await sut.signIn(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.emptyEmail to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .emptyEmail)
            XCTAssertFalse(mockRepository.signInCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.emptyEmail, got \(error)")
        }
    }
    
    func testSignIn_WithInvalidEmailFormat_ShouldThrowError() async {
        // Given
        let email = "invalid-email"
        let password = "validpassword"
        
        // When & Then
        do {
            _ = try await sut.signIn(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.invalidEmailFormat to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .invalidEmailFormat)
            XCTAssertFalse(mockRepository.signInCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.invalidEmailFormat, got \(error)")
        }
    }
    
    func testSignIn_WithEmptyPassword_ShouldThrowError() async {
        // Given
        let email = "test@example.com"
        let password = ""
        
        // When & Then
        do {
            _ = try await sut.signIn(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.emptyPassword to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .emptyPassword)
            XCTAssertFalse(mockRepository.signInCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.emptyPassword, got \(error)")
        }
    }
    
    func testSignIn_WithShortPassword_ShouldThrowError() async {
        // Given
        let email = "test@example.com"
        let password = "123" // Less than minimum required length
        
        // When & Then
        do {
            _ = try await sut.signIn(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.passwordTooShort to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .passwordTooShort)
            XCTAssertFalse(mockRepository.signInCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.passwordTooShort, got \(error)")
        }
    }
    
    func testSignIn_WithRepositoryError_ShouldThrowWrappedError() async {
        // Given
        let email = "test@example.com"
        let password = "validpassword"
        let repositoryError = AuthError.invalidCredentials
        
        mockRepository.setFailedSignIn(error: repositoryError)
        
        // When & Then
        do {
            _ = try await sut.signIn(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.signInFailed to be thrown")
        } catch let error as LoginUseCaseError {
            if case .signInFailed(let underlyingError) = error {
                XCTAssertTrue(underlyingError is AuthError)
            } else {
                XCTFail("Expected LoginUseCaseError.signInFailed, got \(error)")
            }
            XCTAssertTrue(mockRepository.signInCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.signInFailed, got \(error)")
        }
    }
    
    // MARK: - Sign Up Tests
    
    func testSignUp_WithValidData_ShouldReturnUser() async throws {
        // Given
        let email = "newuser@example.com"
        let password = "validpassword"
        let expectedUser = UserModel(id: "456", email: email, displayName: "New User")
        
        mockRepository.setSuccessfulSignUp(user: expectedUser)
        
        // When
        let result = try await sut.signUp(email: email, password: password)
        
        // Then
        XCTAssertTrue(mockRepository.signUpCalled)
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
        XCTAssertEqual(result.displayName, expectedUser.displayName)
    }
    
    func testSignUp_WithWeakPassword_ShouldThrowError() async {
        // Given
        let email = "test@example.com"
        let password = "123" // Too short
        
        // When & Then
        do {
            _ = try await sut.signUp(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.passwordTooShort to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .passwordTooShort)
            XCTAssertFalse(mockRepository.signUpCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.passwordTooShort, got \(error)")
        }
    }
    
    func testSignUp_WithTooLongPassword_ShouldThrowError() async {
        // Given
        let email = "test@example.com"
        let password = String(repeating: "a", count: 51) // Too long
        
        // When & Then
        do {
            _ = try await sut.signUp(email: email, password: password)
            XCTFail("Expected LoginUseCaseError.passwordTooLong to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .passwordTooLong)
            XCTAssertFalse(mockRepository.signUpCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.passwordTooLong, got \(error)")
        }
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOut_WithAuthenticatedUser_ShouldSignOut() async throws {
        // Given
        let user = UserModel(id: "123", email: "test@example.com")
        mockRepository.setAuthenticatedUser(user)
        
        // When
        try await sut.signOut()
        
        // Then
        XCTAssertTrue(mockRepository.signOutCalled)
    }
    
    func testSignOut_WithNoAuthenticatedUser_ShouldThrowError() async {
        // Given
        mockRepository.currentUser = nil
        
        // When & Then
        do {
            try await sut.signOut()
            XCTFail("Expected LoginUseCaseError.userNotAuthenticated to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .userNotAuthenticated)
            XCTAssertFalse(mockRepository.signOutCalled)
        } catch {
            XCTFail("Expected LoginUseCaseError.userNotAuthenticated, got \(error)")
        }
    }
    
    // MARK: - Get Current User Tests
    
    func testGetCurrentUser_WithAuthenticatedUser_ShouldReturnUser() {
        // Given
        let user = UserModel(id: "123", email: "test@example.com")
        mockRepository.setAuthenticatedUser(user)
        
        // When
        let result = sut.getCurrentUser()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, user.id)
        XCTAssertEqual(result?.email, user.email)
        XCTAssertTrue(mockRepository.getCurrentUserCalled)
    }
    
    func testGetCurrentUser_WithNoAuthenticatedUser_ShouldReturnNil() {
        // Given
        mockRepository.currentUser = nil
        
        // When
        let result = sut.getCurrentUser()
        
        // Then
        XCTAssertNil(result)
        XCTAssertTrue(mockRepository.getCurrentUserCalled)
    }
    
    // MARK: - Is User Authenticated Tests
    
    func testIsUserAuthenticated_WithAuthenticatedUser_ShouldReturnTrue() {
        // Given
        let user = UserModel(id: "123", email: "test@example.com")
        mockRepository.setAuthenticatedUser(user)
        
        // When
        let result = sut.isUserAuthenticated()
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testIsUserAuthenticated_WithNoAuthenticatedUser_ShouldReturnFalse() {
        // Given
        mockRepository.currentUser = nil
        
        // When
        let result = sut.isUserAuthenticated()
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - Refresh Token Tests
    
    func testRefreshToken_WithAuthenticatedUser_ShouldReturnNewToken() async throws {
        // Given
        let user = UserModel(id: "123", email: "test@example.com")
        mockRepository.setAuthenticatedUser(user)
        
        // When
        let result = try await sut.refreshToken()
        
        // Then
        XCTAssertFalse(result.isEmpty)
    }
    
    func testRefreshToken_WithNoAuthenticatedUser_ShouldThrowError() async {
        // Given
        mockRepository.currentUser = nil
        
        // When & Then
        do {
            _ = try await sut.refreshToken()
            XCTFail("Expected LoginUseCaseError.userNotAuthenticated to be thrown")
        } catch let error as LoginUseCaseError {
            XCTAssertEqual(error, .userNotAuthenticated)
        } catch {
            XCTFail("Expected LoginUseCaseError.userNotAuthenticated, got \(error)")
        }
    }
    
    // MARK: - Save User Tests
    
    func testSaveUser_ShouldCallRepository() throws {
        // Given
        let user = UserModel(id: "123", email: "test@example.com")
        
        // When
        try sut.saveUser(user)
        
        // Then
        XCTAssertTrue(mockRepository.saveUserCalled)
    }
}

// MARK: - LoginUseCaseError Equatable Extension for Testing

extension LoginUseCaseError: Equatable {
    public static func == (lhs: LoginUseCaseError, rhs: LoginUseCaseError) -> Bool {
        switch (lhs, rhs) {
        case (.emptyEmail, .emptyEmail),
             (.emptyPassword, .emptyPassword),
             (.invalidEmailFormat, .invalidEmailFormat),
             (.passwordTooShort, .passwordTooShort),
             (.passwordTooLong, .passwordTooLong),
             (.weakPassword, .weakPassword),
             (.userNotAuthenticated, .userNotAuthenticated),
             (.sessionExpired, .sessionExpired):
            return true
        case (.signInFailed(let lhsError), .signInFailed(let rhsError)),
             (.signUpFailed(let lhsError), .signUpFailed(let rhsError)),
             (.signOutFailed(let lhsError), .signOutFailed(let rhsError)),
             (.tokenRefreshFailed(let lhsError), .tokenRefreshFailed(let rhsError)):
            return type(of: lhsError) == type(of: rhsError)
        default:
            return false
        }
    }
}