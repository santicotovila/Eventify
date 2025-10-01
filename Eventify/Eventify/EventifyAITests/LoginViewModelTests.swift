import XCTest
@testable import EventifyAI

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    private var sut: LoginViewModel!
    private var mockLoginUseCase: MockLoginUseCase!
    
    override func setUp() {
        super.setUp()
        mockLoginUseCase = MockLoginUseCase()
        sut = LoginViewModel(loginUseCase: mockLoginUseCase)
    }
    
    override func tearDown() {
        sut = nil
        mockLoginUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Security Critical Tests
    
    func testSignIn_WithValidCredentials_ShouldSucceed() async {
        // Given
        let expectedUser = UserModel(id: "123", email: "test@example.com", displayName: "Test User")
        mockLoginUseCase.setSuccessfulSignIn(user: expectedUser)
        
        sut.email = "test@example.com"
        sut.password = "validpassword"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(mockLoginUseCase.signInCalled)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func testSignIn_WithInvalidCredentials_ShouldShowError() async {
        // Given
        mockLoginUseCase.setFailedSignIn(error: AuthError.invalidCredentials)
        
        sut.email = "test@example.com"
        sut.password = "wrongpassword"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(mockLoginUseCase.signInCalled)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testSignIn_WithNetworkError_ShouldShowError() async {
        // Given
        let networkError = NetworkError.noInternetConnection
        mockLoginUseCase.setFailedSignIn(error: AuthError.networkError(networkError))
        
        sut.email = "test@example.com"
        sut.password = "validpassword"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(mockLoginUseCase.signInCalled)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testSignIn_ShouldPassCorrectParametersToUseCase() async {
        // Given
        let expectedUser = UserModel(id: "123", email: "test@example.com", displayName: "Test User")
        mockLoginUseCase.setSuccessfulSignIn(user: expectedUser)
        
        let email = "test@example.com"
        let password = "validpassword"
        
        sut.email = email
        sut.password = password
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(mockLoginUseCase.capturedEmail, email)
        XCTAssertEqual(mockLoginUseCase.capturedPassword, password)
    }
}

// MARK: - Mock LoginUseCase

private final class MockLoginUseCase: LoginUseCaseProtocol {
    
    var signInCalled = false
    var capturedEmail: String?
    var capturedPassword: String?
    var signInResult: Result<UserModel, Error> = .failure(AuthError.invalidCredentials)
    var currentUser: UserModel?
    
    func signIn(email: String, password: String) async throws -> UserModel {
        signInCalled = true
        capturedEmail = email
        capturedPassword = password
        
        switch signInResult {
        case .success(let user):
            currentUser = user
            return user
        case .failure(let error):
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        fatalError("Not implemented for this test")
    }
    
    func signOut() async throws {
        fatalError("Not implemented for this test")
    }
    
    func getCurrentUser() -> UserModel? {
        return currentUser
    }
    
    func isUserAuthenticated() -> Bool {
        return currentUser != nil
    }
    
    func refreshToken() async throws -> String {
        return "mock-token"
    }
    
    func saveUser(_ user: UserModel) throws {
        currentUser = user
    }
    
    func saveUserWithToken(_ user: UserModel, token: String) throws {
        currentUser = user
    }
    
    func setSuccessfulSignIn(user: UserModel) {
        signInResult = .success(user)
    }
    
    func setFailedSignIn(error: Error) {
        signInResult = .failure(error)
    }
}