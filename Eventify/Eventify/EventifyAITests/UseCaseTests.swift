import XCTest
@testable import EventifyAI

final class UseCaseTests: XCTestCase {
    
    var loginUseCase: LoginUseCase!
    var eventsUseCase: EventsUseCase!
    var attendanceUseCase: AttendanceUseCase!
    
    var mockLoginRepository: MockLoginRepository!
    var mockEventsRepository: MockEventsRepository!
    var mockAttendanceRepository: MockAttendanceRepository!
    
    override func setUp() {
        super.setUp()
        
        mockLoginRepository = MockLoginRepository()
        mockEventsRepository = MockEventsRepository()
        mockAttendanceRepository = MockAttendanceRepository()
        
        loginUseCase = LoginUseCase(repository: mockLoginRepository)
        eventsUseCase = EventsUseCase(repository: mockEventsRepository)
        attendanceUseCase = AttendanceUseCase(repository: mockAttendanceRepository)
    }
    
    override func tearDown() {
        loginUseCase = nil
        eventsUseCase = nil
        attendanceUseCase = nil
        mockLoginRepository = nil
        mockEventsRepository = nil
        mockAttendanceRepository = nil
        super.tearDown()
    }
    
    // MARK: - LoginUseCase Tests
    
    func testSignInSuccess() async throws {
        let mockUser = UserModel(
            id: "user-1",
            email: "test@example.com",
            displayName: "Test User"
        )
        mockLoginRepository.signInResult = .success(mockUser)
        
        let result = try await loginUseCase.signIn(email: "test@example.com", password: "password123")
        
        XCTAssertEqual(result.id, "user-1")
        XCTAssertEqual(result.email, "test@example.com")
        XCTAssertEqual(result.displayName, "Test User")
    }
    
    func testSignInWithEmptyEmail() async {
        do {
            _ = try await loginUseCase.signIn(email: "", password: "password123")
            XCTFail("Expected AuthError to be thrown")
        } catch let error as AuthError {
            if case .invalidCredentials = error {
                // Test passed
            } else {
                XCTFail("Expected AuthError.invalidCredentials, got \(error)")
            }
        } catch {
            XCTFail("Expected AuthError, got \(error)")
        }
    }
    
    func testSignInWithShortPassword() async {
        do {
            _ = try await loginUseCase.signIn(email: "test@example.com", password: "123")
            XCTFail("Expected AuthError to be thrown")
        } catch let error as AuthError {
            if case .weakPassword = error {
                // Test passed
            } else {
                XCTFail("Expected AuthError.weakPassword, got \(error)")
            }
        } catch {
            XCTFail("Expected AuthError, got \(error)")
        }
    }
    
    func testSignUpSuccess() async throws {
        let mockUser = UserModel(
            id: "user-1",
            email: "newuser@example.com",
            displayName: "New User"
        )
        mockLoginRepository.signUpResult = .success(mockUser)
        
        let result = try await loginUseCase.signUp(email: "newuser@example.com", password: "password123")
        
        XCTAssertEqual(result.id, "user-1")
        XCTAssertEqual(result.email, "newuser@example.com")
        XCTAssertEqual(result.displayName, "New User")
    }
    
    // MARK: - EventsUseCase Tests
    
    func testCreateEventSuccess() async throws {
        let testEvent = EventModel(
            title: "Test Event",
            description: "Test Description",
            date: Date(),
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User"
        )
        
        let mockCreatedEvent = EventModel(
            id: "event-1",
            title: "Test Event",
            description: "Test Description",
            date: Date(),
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User"
        )
        
        mockEventsRepository.createEventResult = .success(mockCreatedEvent)
        
        let result = try await eventsUseCase.createEvent(testEvent)
        
        XCTAssertEqual(result.id, "event-1")
        XCTAssertEqual(result.title, "Test Event")
    }
    
    func testCreateEventWithEmptyTitle() async {
        let testEvent = EventModel(
            title: "",
            description: "Test Description",
            date: Date(),
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User"
        )
        
        do {
            _ = try await eventsUseCase.createEvent(testEvent)
            XCTFail("Expected EventError to be thrown")
        } catch let error as EventError {
            if case .invalidEventData = error {
                // Test passed
            } else {
                XCTFail("Expected EventError.invalidEventData, got \(error)")
            }
        } catch {
            XCTFail("Expected EventError, got \(error)")
        }
    }
    
    func testCreateEventInThePast() async {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let testEvent = EventModel(
            title: "Past Event",
            description: "Test Description",
            date: pastDate,
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User"
        )
        
        do {
            _ = try await eventsUseCase.createEvent(testEvent)
            XCTFail("Expected EventError to be thrown")
        } catch let error as EventError {
            if case .eventInThePast = error {
                // Test passed
            } else {
                XCTFail("Expected EventError.eventInThePast, got \(error)")
            }
        } catch {
            XCTFail("Expected EventError, got \(error)")
        }
    }
    
    func testGetEventsSuccess() async throws {
        let mockEvents = [
            EventModel(
                id: "event-1",
                title: "Event 1",
                description: "Description 1",
                date: Date(),
                location: "Location 1",
                organizerId: "user-1",
                organizerName: "User 1"
            ),
            EventModel(
                id: "event-2",
                title: "Event 2",
                description: "Description 2",
                date: Date(),
                location: "Location 2",
                organizerId: "user-1",
                organizerName: "User 1"
            )
        ]
        
        mockEventsRepository.getEventsResult = .success(mockEvents)
        
        let result = try await eventsUseCase.getEvents(for: "user-1")
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.title, "Event 1")
        XCTAssertEqual(result.last?.title, "Event 2")
    }
    
    // MARK: - AttendanceUseCase Tests
    
    func testVoteAttendanceSuccess() async throws {
        let mockAttendance = AttendanceModel(
            userId: "user-1",
            eventId: "event-1",
            status: .going,
            userName: "Test User",
            userEmail: "test@example.com"
        )
        
        mockAttendanceRepository.saveAttendanceResult = .success(mockAttendance)
        
        let result = try await attendanceUseCase.voteAttendance(
            userId: "user-1",
            eventId: "event-1",
            status: .going,
            userName: "Test User"
        )
        
        XCTAssertEqual(result.userId, "user-1")
        XCTAssertEqual(result.eventId, "event-1")
        XCTAssertEqual(result.status, .going)
    }
    
    func testVoteAttendanceWithEmptyUserId() async {
        do {
            _ = try await attendanceUseCase.voteAttendance(
                userId: "",
                eventId: "event-1",
                status: .going,
                userName: "Test User"
            )
            XCTFail("Expected EventError to be thrown")
        } catch let error as EventError {
            if case .invalidAttendanceStatus = error {
                // Test passed - the use case should validate input
            } else {
                XCTFail("Expected EventError.invalidAttendanceStatus, got \(error)")
            }
        } catch {
            XCTFail("Expected EventError, got \(error)")
        }
    }
    
    func testGetAttendancesSuccess() async throws {
        let mockAttendances = [
            AttendanceModel(
                userId: "user-1",
                eventId: "event-1",
                status: .going,
                userName: "User 1",
                userEmail: "user1@example.com"
            ),
            AttendanceModel(
                userId: "user-2",
                eventId: "event-1",
                status: .maybe,
                userName: "User 2",
                userEmail: "user2@example.com"
            )
        ]
        
        mockAttendanceRepository.getAttendancesResult = .success(mockAttendances)
        
        let result = try await attendanceUseCase.getAttendances(for: "event-1")
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.status, .going)
        XCTAssertEqual(result.last?.status, .maybe)
    }
}

// MARK: - Mock Repository Classes

class MockLoginRepository: LoginRepositoryProtocol {
    var signInResult: Result<UserModel, Error> = .failure(AuthError.unknown(NSError()))
    var signUpResult: Result<UserModel, Error> = .failure(AuthError.unknown(NSError()))
    var signOutResult: Result<Void, Error> = .success(())
    var currentUser: UserModel?
    
    func signIn(email: String, password: String) async throws -> UserModel {
        switch signInResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        switch signUpResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }
    
    func signOut() async throws {
        switch signOutResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func getCurrentUser() -> UserModel? {
        return currentUser
    }
    
    func refreshToken() async throws -> String {
        return "mock-token"
    }
    
    func isUserAuthenticated() -> Bool {
        return currentUser != nil
    }
    
    func getUserToken() -> String? {
        return "mock-token"
    }
}

class MockEventsRepository: EventsRepositoryProtocol {
    var createEventResult: Result<EventModel, Error> = .failure(EventError.unknown(NSError()))
    var getEventsResult: Result<[EventModel], Error> = .failure(EventError.unknown(NSError()))
    var getEventByIdResult: Result<EventModel?, Error> = .failure(EventError.unknown(NSError()))
    var updateEventResult: Result<EventModel, Error> = .failure(EventError.unknown(NSError()))
    var deleteEventResult: Result<Void, Error> = .success(())
    
    func createEvent(_ event: EventModel) async throws -> EventModel {
        switch createEventResult {
        case .success(let event):
            return event
        case .failure(let error):
            throw error
        }
    }
    
    func getEvents(for userId: String) async throws -> [EventModel] {
        switch getEventsResult {
        case .success(let events):
            return events
        case .failure(let error):
            throw error
        }
    }
    
    func getEventById(_ id: String) async throws -> EventModel? {
        switch getEventByIdResult {
        case .success(let event):
            return event
        case .failure(let error):
            throw error
        }
    }
    
    func updateEvent(_ event: EventModel) async throws -> EventModel {
        switch updateEventResult {
        case .success(let event):
            return event
        case .failure(let error):
            throw error
        }
    }
    
    func deleteEvent(eventId: String) async throws {
        switch deleteEventResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}

class MockAttendanceRepository: AttendanceRepositoryProtocol {
    var getAttendancesResult: Result<[AttendanceModel], Error> = .failure(EventError.unknown(NSError()))
    var getUserAttendanceResult: Result<AttendanceModel?, Error> = .failure(EventError.unknown(NSError()))
    var saveAttendanceResult: Result<AttendanceModel, Error> = .failure(EventError.unknown(NSError()))
    
    func getAttendances(for eventId: String) async throws -> [AttendanceModel] {
        switch getAttendancesResult {
        case .success(let attendances):
            return attendances
        case .failure(let error):
            throw error
        }
    }
    
    func getUserAttendance(userId: String, eventId: String) async throws -> AttendanceModel? {
        switch getUserAttendanceResult {
        case .success(let attendance):
            return attendance
        case .failure(let error):
            throw error
        }
    }
    
    func saveAttendance(userId: String, eventId: String, status: AttendanceStatus, userName: String) async throws -> AttendanceModel {
        switch saveAttendanceResult {
        case .success(let attendance):
            return attendance
        case .failure(let error):
            throw error
        }
    }
}