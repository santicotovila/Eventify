import XCTest
@testable import EventifyAI

/// Tests para el caso de uso de creación de eventos
/// Verifica la lógica de validación y creación de eventos
final class CreateEventUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: CreateEventUseCase!
    private var mockEventRepository: MockEventRepository!
    private var mockAuthRepository: MockAuthRepository!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockEventRepository = MockEventRepository()
        mockAuthRepository = MockAuthRepository()
        sut = CreateEventUseCase(
            eventRepository: mockEventRepository,
            authRepository: mockAuthRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockEventRepository = nil
        mockAuthRepository = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testCreateEvent_WithValidData_ShouldReturnEvent() async throws {
        // Given
        let user = User(id: "test_user", email: "test@example.com")
        mockAuthRepository.currentUser = user
        
        let title = "Test Event"
        let description = "Test Description"
        let location = "Test Location"
        let dateTime = Date().addingTimeInterval(3600) // 1 hora en el futuro
        
        // When
        let result = try await sut.execute(
            title: title,
            description: description,
            dateTime: dateTime,
            location: location
        )
        
        // Then
        XCTAssertEqual(result.title, title)
        XCTAssertEqual(result.description, description)
        XCTAssertEqual(result.location, location)
        XCTAssertEqual(result.dateTime, dateTime)
        XCTAssertEqual(result.creatorId, user.id)
        XCTAssertEqual(result.creatorEmail, user.email)
        XCTAssertTrue(mockEventRepository.createEventCalled)
    }
    
    func testCreateEvent_WithWhitespaceInFields_ShouldTrimWhitespace() async throws {
        // Given
        let user = User(id: "test_user", email: "test@example.com")
        mockAuthRepository.currentUser = user
        
        let title = "  Test Event  "
        let description = "  Test Description  "
        let location = "  Test Location  "
        let dateTime = Date().addingTimeInterval(3600)
        
        // When
        let result = try await sut.execute(
            title: title,
            description: description,
            dateTime: dateTime,
            location: location
        )
        
        // Then
        XCTAssertEqual(result.title, "Test Event")
        XCTAssertEqual(result.description, "Test Description")
        XCTAssertEqual(result.location, "Test Location")
    }
    
    // MARK: - Failure Cases
    
    func testCreateEvent_WithNoAuthenticatedUser_ShouldThrowError() async {
        // Given
        mockAuthRepository.currentUser = nil
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.execute(
                title: "Test",
                description: "Test",
                dateTime: Date().addingTimeInterval(3600),
                location: "Test"
            )
        ) { error in
            XCTAssertTrue(error is EventError)
            XCTAssertEqual(error as? EventError, .userNotAuthenticated)
        }
    }
    
    func testCreateEvent_WithEmptyTitle_ShouldThrowError() async {
        // Given
        let user = User(id: "test_user", email: "test@example.com")
        mockAuthRepository.currentUser = user
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.execute(
                title: "",
                description: "Test Description",
                dateTime: Date().addingTimeInterval(3600),
                location: "Test Location"
            )
        ) { error in
            XCTAssertEqual(error as? EventError, .emptyTitle)
        }
    }
    
    func testCreateEvent_WithShortTitle_ShouldThrowError() async {
        // Given
        let user = User(id: "test_user", email: "test@example.com")
        mockAuthRepository.currentUser = user
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.execute(
                title: "AB", // Solo 2 caracteres
                description: "Test Description",
                dateTime: Date().addingTimeInterval(3600),
                location: "Test Location"
            )
        ) { error in
            XCTAssertEqual(error as? EventError, .titleTooShort)
        }
    }
    
    func testCreateEvent_WithPastDate_ShouldThrowError() async {
        // Given
        let user = User(id: "test_user", email: "test@example.com")
        mockAuthRepository.currentUser = user
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.execute(
                title: "Test Event",
                description: "Test Description",
                dateTime: Date().addingTimeInterval(-3600), // 1 hora en el pasado
                location: "Test Location"
            )
        ) { error in
            XCTAssertEqual(error as? EventError, .invalidDateTime)
        }
    }
}