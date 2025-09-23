import XCTest
@testable import EventifyAI

final class RepositoryTests: XCTestCase {
    
    var loginRepository: DefaultLoginRepository!
    var eventsRepository: DefaultEventsRepository!
    var attendanceRepository: DefaultAttendanceRepository!
    var mockNetworkLogin: MockNetworkLogin!
    var mockNetworkEvents: MockNetworkEvents!
    var mockNetworkAttendance: MockNetworkAttendance!
    
    override func setUp() {
        super.setUp()
        
        mockNetworkLogin = MockNetworkLogin()
        mockNetworkEvents = MockNetworkEvents()
        mockNetworkAttendance = MockNetworkAttendance()
        
        loginRepository = DefaultLoginRepository(
            networkLogin: mockNetworkLogin,
            keychain: KeyChainEventify.shared
        )
        
        eventsRepository = DefaultEventsRepository(
            networkEvents: mockNetworkEvents,
            keychain: KeyChainEventify.shared
        )
        
        attendanceRepository = DefaultAttendanceRepository(
            networkAttendance: mockNetworkAttendance,
            keychain: KeyChainEventify.shared
        )
    }
    
    override func tearDown() {
        loginRepository = nil
        eventsRepository = nil
        attendanceRepository = nil
        mockNetworkLogin = nil
        mockNetworkEvents = nil
        mockNetworkAttendance = nil
        super.tearDown()
    }
    
    // MARK: - LoginRepository Tests
    
    func testSignInSuccess() async throws {
        let mockUserDTO = UserDTO(
            id: "test-user-1",
            email: "test@example.com",
            displayName: "Test User",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T00:00:00Z"
        )
        mockNetworkLogin.signInResult = .success(mockUserDTO)
        
        let user = try await loginRepository.signIn(email: "test@example.com", password: "password123")
        
        XCTAssertEqual(user.id, "test-user-1")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "Test User")
    }
    
    func testSignInNetworkError() async {
        mockNetworkLogin.signInResult = .failure(NetworkError.unauthorized)
        
        do {
            _ = try await loginRepository.signIn(email: "test@example.com", password: "wrong")
            XCTFail("Expected AuthError to be thrown")
        } catch let error as AuthError {
            if case .networkError = error {
                // Test passed
            } else {
                XCTFail("Expected AuthError.networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected AuthError, got \(error)")
        }
    }
    
    func testSignInMappingError() async {
        let invalidUserDTO = UserDTO(
            id: "test-user-1",
            email: "test@example.com",
            displayName: "Test User",
            createdAt: "invalid-date",
            updatedAt: "invalid-date"
        )
        mockNetworkLogin.signInResult = .success(invalidUserDTO)
        
        do {
            _ = try await loginRepository.signIn(email: "test@example.com", password: "password123")
            XCTFail("Expected DomainError to be thrown")
        } catch is DomainError {
            // Test passed
        } catch {
            XCTFail("Expected DomainError, got \(error)")
        }
    }
    
    // MARK: - EventsRepository Tests
    
    func testCreateEventSuccess() async throws {
        let testEvent = EventModel(
            id: "test-event",
            title: "Test Event",
            description: "Test Description",
            date: Date(),
            location: "Test Location",
            organizerId: "test-user",
            organizerName: "Test User"
        )
        
        let mockEventDTO = EventDTO(
            id: "created-event-id",
            title: "Test Event",
            description: "Test Description",
            date: "2024-01-01T00:00:00Z",
            location: "Test Location",
            organizerId: "test-user",
            organizerName: "Test User",
            isAllDay: false,
            tags: [],
            maxAttendees: nil,
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T00:00:00Z"
        )
        
        mockNetworkEvents.createEventResult = .success(mockEventDTO)
        
        let createdEvent = try await eventsRepository.createEvent(testEvent)
        
        XCTAssertEqual(createdEvent.id, "created-event-id")
        XCTAssertEqual(createdEvent.title, "Test Event")
    }
    
    func testGetEventsSuccess() async throws {
        let mockEventDTOs = [
            EventDTO(
                id: "event-1",
                title: "Event 1",
                description: "Description 1",
                date: "2024-01-01T00:00:00Z",
                location: "Location 1",
                organizerId: "user-1",
                organizerName: "User 1",
                isAllDay: false,
                tags: [],
                maxAttendees: nil,
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z"
            )
        ]
        
        mockNetworkEvents.getEventsResult = .success(mockEventDTOs)
        
        let events = try await eventsRepository.getEvents(for: "user-1")
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.title, "Event 1")
    }
    
    // MARK: - AttendanceRepository Tests
    
    func testSaveAttendanceSuccess() async throws {
        let mockAttendanceDTO = AttendanceDTO(
            id: "attendance-1",
            userId: "user-1",
            eventId: "event-1",
            status: "going",
            userName: "Test User",
            userEmail: "test@example.com",
            createdAt: "2024-01-01T00:00:00Z"
        )
        
        mockNetworkAttendance.saveAttendanceResult = .success(mockAttendanceDTO)
        
        let attendance = try await attendanceRepository.saveAttendance(
            userId: "user-1",
            eventId: "event-1",
            status: .going,
            userName: "Test User"
        )
        
        XCTAssertEqual(attendance.userId, "user-1")
        XCTAssertEqual(attendance.eventId, "event-1")
        XCTAssertEqual(attendance.status, .going)
    }
}

// MARK: - Mock Classes

class MockNetworkLogin: NetworkLoginProtocol {
    var signInResult: Result<UserDTO, Error> = .failure(NetworkError.unknown(NSError()))
    var signUpResult: Result<UserDTO, Error> = .failure(NetworkError.unknown(NSError()))
    
    func signIn(email: String, password: String) async throws -> UserDTO {
        switch signInResult {
        case .success(let userDTO):
            return userDTO
        case .failure(let error):
            throw error
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws -> UserDTO {
        switch signUpResult {
        case .success(let userDTO):
            return userDTO
        case .failure(let error):
            throw error
        }
    }
    
    func signOut() async throws {
        // Mock implementation
    }
    
    func refreshToken() async throws -> String {
        return "mock-token"
    }
}

class MockNetworkEvents: NetworkEventsProtocol {
    var getEventsResult: Result<[EventDTO], Error> = .failure(NetworkError.unknown(NSError()))
    var getEventByIdResult: Result<EventDTO?, Error> = .failure(NetworkError.unknown(NSError()))
    var createEventResult: Result<EventDTO, Error> = .failure(NetworkError.unknown(NSError()))
    var updateEventResult: Result<EventDTO, Error> = .failure(NetworkError.unknown(NSError()))
    
    func getEvents(userId: String) async throws -> [EventDTO] {
        switch getEventsResult {
        case .success(let events):
            return events
        case .failure(let error):
            throw error
        }
    }
    
    func getEventById(eventId: String) async throws -> EventDTO? {
        switch getEventByIdResult {
        case .success(let event):
            return event
        case .failure(let error):
            throw error
        }
    }
    
    func createEvent(event: CreateEventDTO) async throws -> EventDTO {
        switch createEventResult {
        case .success(let event):
            return event
        case .failure(let error):
            throw error
        }
    }
    
    func updateEvent(eventId: String, event: EventDTO) async throws -> EventDTO {
        switch updateEventResult {
        case .success(let event):
            return event
        case .failure(let error):
            throw error
        }
    }
    
    func deleteEvent(eventId: String) async throws {
        // Mock implementation
    }
}

class MockNetworkAttendance: NetworkAttendanceProtocol {
    var getAttendancesResult: Result<[AttendanceDTO], Error> = .failure(NetworkError.unknown(NSError()))
    var getUserAttendanceResult: Result<AttendanceDTO?, Error> = .failure(NetworkError.unknown(NSError()))
    var saveAttendanceResult: Result<AttendanceDTO, Error> = .failure(NetworkError.unknown(NSError()))
    
    func getAttendances(eventId: String) async throws -> [AttendanceDTO] {
        switch getAttendancesResult {
        case .success(let attendances):
            return attendances
        case .failure(let error):
            throw error
        }
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceDTO? {
        switch getUserAttendanceResult {
        case .success(let attendance):
            return attendance
        case .failure(let error):
            throw error
        }
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceDTO {
        switch saveAttendanceResult {
        case .success(let attendance):
            return attendance
        case .failure(let error):
            throw error
        }
    }
}