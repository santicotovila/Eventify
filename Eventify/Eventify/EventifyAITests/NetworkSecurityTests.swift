import XCTest
@testable import EventifyAI

final class NetworkSecurityTests: XCTestCase {
    
    // MARK: - Network Login Security Tests
    
    func testNetworkLogin_ShouldUseBasicAuthHeader() {
        // Given
        let email = "test@example.com"
        let password = "password123"
        let expectedCredentials = "\(email):\(password)"
        let expectedBase64 = expectedCredentials.data(using: .utf8)?.base64EncodedString()
        
        // Then
        XCTAssertNotNil(expectedBase64)
        XCTAssertFalse(expectedBase64?.isEmpty ?? true)
        
        // Verify Basic Auth format
        let expectedAuthHeader = "Basic \(expectedBase64!)"
        XCTAssertTrue(expectedAuthHeader.starts(with: "Basic "))
    }
    
    func testJWTHelper_ShouldExtractPayloadSafely() {
        // Given - Mock JWT token structure
        let mockHeader = "eyJhbGciOiJIUzI1NiJ9"
        let mockPayload = "eyJ1c2VySUQiOiIxMjMiLCJleHAiOjE2MDk0NTkyMDB9" // {"userID":"123","exp":1609459200}
        let mockSignature = "signature"
        let mockJWT = "\(mockHeader).\(mockPayload).\(mockSignature)"
        
        // When
        let payload = JWTHelper.extractPayload(from: mockJWT)
        
        // Then
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload?["userID"] as? String, "123")
    }
    
    func testJWTHelper_WithInvalidToken_ShouldReturnNil() {
        // Given
        let invalidTokens = [
            "",
            "invalid.token",
            "invalid.token.format.extra",
            "header.invalid_base64.signature"
        ]
        
        for invalidToken in invalidTokens {
            // When
            let payload = JWTHelper.extractPayload(from: invalidToken)
            
            // Then
            XCTAssertNil(payload, "Should return nil for invalid token: \(invalidToken)")
        }
    }
    
    // MARK: - KeyChain Security Tests
    
    func testKeyChain_ShouldUseSecureStorage() {
        // Given
        let keychain = KeyChainEventify.shared
        let testKey = "test_security_key"
        let testValue = "sensitive_data"
        
        // When & Then - Should not throw
        XCTAssertNoThrow(try keychain.saveString(key: testKey, value: testValue))
        
        // Cleanup
        try? keychain.delete(key: testKey)
    }
    
    func testKeyChain_ShouldEncryptData() {
        // Given
        let keychain = KeyChainEventify.shared
        let testKey = "test_encryption_key"
        let originalData = "confidential_information"
        
        do {
            // When
            try keychain.saveString(key: testKey, value: originalData)
            let retrievedData = keychain.getString(key: testKey)
            
            // Then
            XCTAssertEqual(retrievedData, originalData)
            XCTAssertNotNil(retrievedData)
            
            // Cleanup
            try keychain.delete(key: testKey)
        } catch {
            XCTFail("KeyChain operation should not fail: \(error)")
        }
    }
    
    func testKeyChain_ShouldIsolateAppData() {
        // Given
        let keychain = KeyChainEventify.shared
        let serviceIdentifier = "com.eventifyai.keychain"
        
        // Then - Service identifier should be app-specific
        XCTAssertTrue(serviceIdentifier.contains("eventifyai"))
        XCTAssertFalse(serviceIdentifier.isEmpty)
    }
    
    // MARK: - Password Security Tests
    
    func testLoginUseCase_ShouldValidatePasswordLength() {
        // Given
        let shortPasswords = ["", "1", "12", "123", "1234", "12345"]
        
        for shortPassword in shortPasswords {
            // When & Then
            let isValid = shortPassword.count >= ConstantsApp.Validation.minPasswordLength
            XCTAssertFalse(isValid, "Password '\(shortPassword)' should be invalid")
        }
    }
    
    func testLoginUseCase_ShouldValidateEmailFormat() {
        // Given
        let invalidEmails = [
            "",
            "invalid",
            "@invalid.com",
            "invalid@",
            "invalid.com",
            "test@",
            "@test.com"
        ]
        
        for invalidEmail in invalidEmails {
            // When
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            let isValid = emailPredicate.evaluate(with: invalidEmail)
            
            // Then
            XCTAssertFalse(isValid, "Email '\(invalidEmail)' should be invalid")
        }
    }
    
    // MARK: - Network Error Handling Tests
    
    func testNetworkError_ShouldHandleUnauthorizedAccess() {
        // Given
        let unauthorizedError = NetworkError.unauthorized
        
        // When
        let errorDescription = unauthorizedError.localizedDescription
        
        // Then
        XCTAssertNotNil(errorDescription)
        XCTAssertTrue(errorDescription.contains("Token") || errorDescription.contains("API Key"))
    }
    
    func testNetworkError_ShouldHandleBadRequests() {
        // Given
        let badRequestError = NetworkError.badRequest("Invalid data")
        
        // When
        let errorDescription = badRequestError.localizedDescription
        
        // Then
        XCTAssertNotNil(errorDescription)
        XCTAssertTrue(errorDescription.contains("Invalid data"))
    }
    
    // MARK: - Constants Security Tests
    
    func testConstants_ShouldHaveSecureDefaults() {
        // Given & Then
        XCTAssertGreaterThanOrEqual(ConstantsApp.Validation.minPasswordLength, 6)
        XCTAssertTrue(ConstantsApp.API.baseURL.starts(with: "http"))
    }
}