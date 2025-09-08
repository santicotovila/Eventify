/*
 * EventifyAITests.swift
 * EventifyAITests
 *
 * Suite principal de tests para EventifyAI
 * Arquitectura: Clean Architecture + MVVM + @Observable
 * 
 * Desarrollado por: Javier Gómez
 * Fecha: 8 Septiembre 2025
 * Versión: 1.0.0
 *
 * Descripción:
 * Tests principales para verificar la funcionalidad de la aplicación EventifyAI,
 * incluyendo ViewModels, UseCases, y componentes de la arquitectura.
 * 
 * Tipos de tests:
 * - Tests de ViewModels (@Observable)
 * - Tests de UseCases (lógica de negocio)
 * - Tests de modelos de datos
 * - Tests de integración básica
 */

import XCTest
import Foundation
@testable import EventifyAI

// MARK: - Main Test Class
final class EventifyAITests: XCTestCase {
    
    // MARK: - Properties
    private var mockLoginRepository: MockLoginRepository!
    private var mockEventsRepository: MockEventsRepository!
    private var mockAttendanceRepository: MockAttendanceRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        // Configuración inicial para cada test
        mockLoginRepository = MockLoginRepository()
        mockEventsRepository = MockEventsRepository()
        mockAttendanceRepository = MockAttendanceRepository()
    }
    
    override func tearDownWithError() throws {
        // Limpieza después de cada test
        mockLoginRepository = nil
        mockEventsRepository = nil
        mockAttendanceRepository = nil
    }
    
    // MARK: - Model Tests
    
    func testUserModelCreation() throws {
        // Given
        let userId = "test-user-123"
        let userName = "Test User"
        let userEmail = "test@example.com"
        
        // When
        let user = UserModel(
            id: userId,
            email: userEmail,
            name: userName
        )
        
        // Then
        XCTAssertEqual(user.id, userId)
        XCTAssertEqual(user.name, userName)
        XCTAssertEqual(user.email, userEmail)
    }
    
    func testEventModelCreation() throws {
        // Given
        let eventId = "event-123"
        let eventTitle = "Test Event"
        let eventDescription = "This is a test event"
        let eventLocation = "Test Location"
        let eventDate = Date()
        let organizerId = "organizer-123"
        let organizerName = "Test Organizer"
        
        // When
        let event = EventModel(
            id: eventId,
            title: eventTitle,
            description: eventDescription,
            date: eventDate,
            location: eventLocation,
            organizerId: organizerId,
            organizerName: organizerName
        )
        
        // Then
        XCTAssertEqual(event.id, eventId)
        XCTAssertEqual(event.title, eventTitle)
        XCTAssertEqual(event.description, eventDescription)
        XCTAssertEqual(event.location, eventLocation)
        XCTAssertEqual(event.organizerId, organizerId)
        XCTAssertEqual(event.organizerName, organizerName)
    }
    
    func testAttendanceModelCreation() throws {
        // Given
        let attendanceId = "attendance-123"
        let eventId = "event-123"
        let userId = "user-123"
        let userName = "Test User"
        let userEmail = "test@example.com"
        let status = AttendanceStatus.going
        
        // When
        let attendance = AttendanceModel(
            id: attendanceId,
            eventId: eventId,
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            status: status
        )
        
        // Then
        XCTAssertEqual(attendance.id, attendanceId)
        XCTAssertEqual(attendance.eventId, eventId)
        XCTAssertEqual(attendance.userId, userId)
        XCTAssertEqual(attendance.userName, userName)
        XCTAssertEqual(attendance.userEmail, userEmail)
        XCTAssertEqual(attendance.status, status)
    }
    
    // MARK: - ViewModel Tests
    
    @MainActor
    func testLoginViewModelInitialization() async throws {
        // Given
        let loginUseCase = LoginUseCase(repository: mockLoginRepository)
        let expectationCalled = expectation(description: "onUserSignedIn called")
        var capturedUser: UserModel?
        
        // When
        let viewModel = LoginViewModel(
            loginUseCase: loginUseCase,
            onUserSignedIn: { user in
                capturedUser = user
                expectationCalled.fulfill()
            }
        )
        
        // Then
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isSignUp)
        XCTAssertEqual(viewModel.loginState, .none)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    @MainActor
    func testLoginViewModelAuthentication() async throws {
        // Given
        let testUser = UserModel(
            id: "test-user",
            email: "test@example.com",
            name: "Test User"
        )
        
        mockLoginRepository.mockUser = testUser
        let loginUseCase = LoginUseCase(repository: mockLoginRepository)
        
        let expectationCalled = expectation(description: "onUserSignedIn called")
        var capturedUser: UserModel?
        
        let viewModel = LoginViewModel(
            loginUseCase: loginUseCase,
            onUserSignedIn: { user in
                capturedUser = user
                expectationCalled.fulfill()
            }
        )
        
        // When
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        await viewModel.authenticate()
        
        // Then
        await fulfillment(of: [expectationCalled], timeout: 2.0)
        
        XCTAssertEqual(capturedUser?.email, testUser.email)
        XCTAssertEqual(viewModel.loginState, .success)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    @MainActor
    func testEventsViewModelInitialization() async throws {
        // Given
        let eventsUseCase = EventsUseCase(repository: mockEventsRepository)
        let loginUseCase = LoginUseCase(repository: mockLoginRepository)
        
        // When
        let viewModel = EventsViewModel(
            eventsUseCase: eventsUseCase,
            loginUseCase: loginUseCase
        )
        
        // Then
        XCTAssertTrue(viewModel.events.isEmpty)
        XCTAssertEqual(viewModel.eventsState, .none)
        XCTAssertNil(viewModel.selectedEvent)
        XCTAssertFalse(viewModel.showAlert)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.showCreateEvent)
    }
    
    // MARK: - UseCase Tests
    
    func testLoginUseCaseSignIn() async throws {
        // Given
        let testUser = UserModel(
            id: "test-user",
            email: "test@example.com",
            name: "Test User"
        )
        
        mockLoginRepository.mockUser = testUser
        let loginUseCase = LoginUseCase(repository: mockLoginRepository)
        
        // When
        let result = try await loginUseCase.signIn(
            email: "test@example.com",
            password: "password123"
        )
        
        // Then
        XCTAssertEqual(result.email, testUser.email)
        XCTAssertEqual(result.name, testUser.name)
    }
    
    func testLoginUseCaseSignUp() async throws {
        // Given
        let testUser = UserModel(
            id: "new-user",
            email: "new@example.com",
            name: "New User"
        )
        
        mockLoginRepository.mockUser = testUser
        let loginUseCase = LoginUseCase(repository: mockLoginRepository)
        
        // When
        let result = try await loginUseCase.signUp(
            email: "new@example.com",
            password: "password123"
        )
        
        // Then
        XCTAssertEqual(result.email, testUser.email)
        XCTAssertEqual(result.name, testUser.name)
    }
    
    func testEventsUseCaseCreateEvent() async throws {
        // Given
        let newEvent = EventModel(
            id: "",
            title: "New Test Event",
            description: "Test Description",
            date: Date(),
            location: "Test Location",
            organizerId: "organizer-123",
            organizerName: "Test Organizer"
        )
        
        let createdEvent = EventModel(
            id: "created-event-123",
            title: newEvent.title,
            description: newEvent.description,
            date: newEvent.date,
            location: newEvent.location,
            organizerId: newEvent.organizerId,
            organizerName: newEvent.organizerName
        )
        
        mockEventsRepository.mockCreatedEvent = createdEvent
        let eventsUseCase = EventsUseCase(repository: mockEventsRepository)
        
        // When
        let result = try await eventsUseCase.createEvent(newEvent)
        
        // Then
        XCTAssertEqual(result.title, newEvent.title)
        XCTAssertEqual(result.description, newEvent.description)
        XCTAssertEqual(result.location, newEvent.location)
        XCTAssertFalse(result.id.isEmpty)
    }
    
    // MARK: - Status Model Tests
    
    func testStatusModelStates() throws {
        // Given & When & Then
        let noneState: StatusModel = .none
        let loadingState: StatusModel = .loading
        let successState: StatusModel = .success
        let errorState: StatusModel = .error("Test error")
        
        XCTAssertEqual(noneState, .none)
        XCTAssertEqual(loadingState, .loading)
        XCTAssertEqual(successState, .success)
        
        if case .error(let message) = errorState {
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    // MARK: - Performance Tests
    
    func testEventModelPerformance() throws {
        measure {
            // Crear 1000 eventos para medir performance
            for i in 0..<1000 {
                let event = EventModel(
                    id: "event-\(i)",
                    title: "Event \(i)",
                    description: "Description \(i)",
                    date: Date(),
                    location: "Location \(i)",
                    organizerId: "organizer-\(i)",
                    organizerName: "Organizer \(i)"
                )
                
                // Verificar que se creó correctamente
                XCTAssertEqual(event.title, "Event \(i)")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringValidation() throws {
        // Given
        let emptyEmail = ""
        let emptyPassword = ""
        
        // When
        let isValidEmail = !emptyEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isValidPassword = !emptyPassword.isEmpty
        
        // Then
        XCTAssertFalse(isValidEmail)
        XCTAssertFalse(isValidPassword)
    }
    
    func testDateComparisons() throws {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let now = Date()
        
        // When & Then
        XCTAssertTrue(pastDate < now)
        XCTAssertTrue(futureDate > now)
        XCTAssertFalse(pastDate > now)
        XCTAssertFalse(futureDate < now)
    }
    
    // MARK: - Mock Validation Tests
    
    func testMockRepositoriesWork() throws {
        // Test Login Repository
        XCTAssertNotNil(mockLoginRepository)
        
        // Test Events Repository  
        XCTAssertNotNil(mockEventsRepository)
        
        // Test Attendance Repository
        XCTAssertNotNil(mockAttendanceRepository)
    }
}

// MARK: - Mock Repositories

class MockLoginRepository: LoginRepositoryProtocol {
    var mockUser: UserModel?
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    
    func signIn(email: String, password: String) async throws -> UserModel {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let user = mockUser else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        return user
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let user = mockUser else {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
        }
        
        return user
    }
    
    func signOut() async throws {
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    func getCurrentUser() -> UserModel? {
        return mockUser
    }
}

class MockEventsRepository: EventsRepositoryProtocol {
    var mockEvents: [EventModel] = []
    var mockEvent: EventModel?
    var mockCreatedEvent: EventModel?
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    
    func getEvents(for userId: String) async throws -> [EventModel] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockEvents
    }
    
    func getEventById(_ id: String) async throws -> EventModel? {
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockEvent
    }
    
    func createEvent(_ event: EventModel) async throws -> EventModel {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let created = mockCreatedEvent else {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create event"])
        }
        
        return created
    }
}

class MockAttendanceRepository: AttendanceRepositoryProtocol {
    var mockAttendances: [AttendanceModel] = []
    var mockAttendance: AttendanceModel?
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
    
    func getAttendances(for eventId: String) async throws -> [AttendanceModel] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockAttendances
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel? {
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockAttendance
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let saved = mockAttendance else {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to save attendance"])
        }
        
        return saved
    }
}