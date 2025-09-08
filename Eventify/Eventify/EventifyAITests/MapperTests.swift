import XCTest
@testable import EventifyAI

final class MapperTests: XCTestCase {
    
    let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - UserMapper Tests
    
    func testUserMapperToDTOSuccess() {
        let testDate = Date()
        let userModel = UserModel(
            id: "user-1",
            email: "test@example.com",
            displayName: "Test User",
            createdAt: testDate,
            updatedAt: testDate
        )
        
        let userDTO = UserMapper.toDTO(from: userModel)
        
        XCTAssertEqual(userDTO.id, "user-1")
        XCTAssertEqual(userDTO.email, "test@example.com")
        XCTAssertEqual(userDTO.displayName, "Test User")
        XCTAssertEqual(userDTO.createdAt, dateFormatter.string(from: testDate))
        XCTAssertEqual(userDTO.updatedAt, dateFormatter.string(from: testDate))
    }
    
    func testUserMapperToModelSuccess() {
        let testDateString = "2024-01-15T10:30:00Z"
        let userDTO = UserDTO(
            id: "user-1",
            email: "test@example.com",
            displayName: "Test User",
            createdAt: testDateString,
            updatedAt: testDateString
        )
        
        let userModel = UserMapper.toModel(from: userDTO)
        
        XCTAssertNotNil(userModel)
        XCTAssertEqual(userModel?.id, "user-1")
        XCTAssertEqual(userModel?.email, "test@example.com")
        XCTAssertEqual(userModel?.displayName, "Test User")
        XCTAssertEqual(userModel?.createdAt, dateFormatter.date(from: testDateString))
        XCTAssertEqual(userModel?.updatedAt, dateFormatter.date(from: testDateString))
    }
    
    func testUserMapperToModelWithInvalidDate() {
        let userDTO = UserDTO(
            id: "user-1",
            email: "test@example.com",
            displayName: "Test User",
            createdAt: "invalid-date",
            updatedAt: "2024-01-15T10:30:00Z"
        )
        
        let userModel = UserMapper.toModel(from: userDTO)
        
        XCTAssertNil(userModel)
    }
    
    func testUserMapperToCreateDTO() {
        let userModel = UserModel(
            id: "user-1",
            email: "test@example.com",
            displayName: "Test User"
        )
        
        let createDTO = UserMapper.toCreateDTO(from: userModel)
        
        XCTAssertEqual(createDTO.email, "test@example.com")
        XCTAssertEqual(createDTO.displayName, "Test User")
    }
    
    // MARK: - EventMapper Tests
    
    func testEventMapperToDTOSuccess() {
        let testDate = Date()
        let eventModel = EventModel(
            id: "event-1",
            title: "Test Event",
            description: "Test Description",
            date: testDate,
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User",
            isAllDay: false,
            tags: ["test", "example"],
            maxAttendees: 50,
            createdAt: testDate,
            updatedAt: testDate
        )
        
        let eventDTO = EventMapper.toDTO(from: eventModel)
        
        XCTAssertEqual(eventDTO.id, "event-1")
        XCTAssertEqual(eventDTO.title, "Test Event")
        XCTAssertEqual(eventDTO.description, "Test Description")
        XCTAssertEqual(eventDTO.date, dateFormatter.string(from: testDate))
        XCTAssertEqual(eventDTO.location, "Test Location")
        XCTAssertEqual(eventDTO.organizerId, "user-1")
        XCTAssertEqual(eventDTO.organizerName, "Test User")
        XCTAssertEqual(eventDTO.isAllDay, false)
        XCTAssertEqual(eventDTO.tags, ["test", "example"])
        XCTAssertEqual(eventDTO.maxAttendees, 50)
        XCTAssertEqual(eventDTO.createdAt, dateFormatter.string(from: testDate))
        XCTAssertEqual(eventDTO.updatedAt, dateFormatter.string(from: testDate))
    }
    
    func testEventMapperToModelSuccess() {
        let testDateString = "2024-01-15T10:30:00Z"
        let eventDTO = EventDTO(
            id: "event-1",
            title: "Test Event",
            description: "Test Description",
            date: testDateString,
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User",
            isAllDay: false,
            tags: ["test", "example"],
            maxAttendees: 50,
            createdAt: testDateString,
            updatedAt: testDateString
        )
        
        let eventModel = EventMapper.toModel(from: eventDTO)
        
        XCTAssertNotNil(eventModel)
        XCTAssertEqual(eventModel?.id, "event-1")
        XCTAssertEqual(eventModel?.title, "Test Event")
        XCTAssertEqual(eventModel?.description, "Test Description")
        XCTAssertEqual(eventModel?.date, dateFormatter.date(from: testDateString))
        XCTAssertEqual(eventModel?.location, "Test Location")
        XCTAssertEqual(eventModel?.organizerId, "user-1")
        XCTAssertEqual(eventModel?.organizerName, "Test User")
        XCTAssertEqual(eventModel?.isAllDay, false)
        XCTAssertEqual(eventModel?.tags, ["test", "example"])
        XCTAssertEqual(eventModel?.maxAttendees, 50)
        XCTAssertEqual(eventModel?.createdAt, dateFormatter.date(from: testDateString))
        XCTAssertEqual(eventModel?.updatedAt, dateFormatter.date(from: testDateString))
    }
    
    func testEventMapperToModelWithInvalidDate() {
        let eventDTO = EventDTO(
            id: "event-1",
            title: "Test Event",
            description: "Test Description",
            date: "invalid-date",
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User",
            isAllDay: false,
            tags: [],
            maxAttendees: nil,
            createdAt: "2024-01-15T10:30:00Z",
            updatedAt: "2024-01-15T10:30:00Z"
        )
        
        let eventModel = EventMapper.toModel(from: eventDTO)
        
        XCTAssertNil(eventModel)
    }
    
    func testEventMapperToCreateDTO() {
        let testDate = Date()
        let eventModel = EventModel(
            title: "Test Event",
            description: "Test Description",
            date: testDate,
            location: "Test Location",
            organizerId: "user-1",
            organizerName: "Test User",
            isAllDay: true,
            tags: ["workshop"],
            maxAttendees: 25
        )
        
        let createDTO = EventMapper.toCreateDTO(from: eventModel)
        
        XCTAssertEqual(createDTO.title, "Test Event")
        XCTAssertEqual(createDTO.description, "Test Description")
        XCTAssertEqual(createDTO.date, dateFormatter.string(from: testDate))
        XCTAssertEqual(createDTO.location, "Test Location")
        XCTAssertEqual(createDTO.organizerId, "user-1")
        XCTAssertEqual(createDTO.organizerName, "Test User")
        XCTAssertEqual(createDTO.isAllDay, true)
        XCTAssertEqual(createDTO.tags, ["workshop"])
        XCTAssertEqual(createDTO.maxAttendees, 25)
    }
    
    // MARK: - AttendanceMapper Tests
    
    func testAttendanceMapperToDTOSuccess() {
        let testDate = Date()
        let attendanceModel = AttendanceModel(
            id: "attendance-1",
            userId: "user-1",
            eventId: "event-1",
            status: .going,
            userName: "Test User",
            userEmail: "test@example.com",
            createdAt: testDate
        )
        
        let attendanceDTO = AttendanceMapper.toDTO(from: attendanceModel)
        
        XCTAssertEqual(attendanceDTO.id, "attendance-1")
        XCTAssertEqual(attendanceDTO.userId, "user-1")
        XCTAssertEqual(attendanceDTO.eventId, "event-1")
        XCTAssertEqual(attendanceDTO.status, "going")
        XCTAssertEqual(attendanceDTO.userName, "Test User")
        XCTAssertEqual(attendanceDTO.userEmail, "test@example.com")
        XCTAssertEqual(attendanceDTO.createdAt, dateFormatter.string(from: testDate))
    }
    
    func testAttendanceMapperToModelSuccess() {
        let testDateString = "2024-01-15T10:30:00Z"
        let attendanceDTO = AttendanceDTO(
            id: "attendance-1",
            userId: "user-1",
            eventId: "event-1",
            status: "maybe",
            userName: "Test User",
            userEmail: "test@example.com",
            createdAt: testDateString
        )
        
        let attendanceModel = AttendanceMapper.toModel(from: attendanceDTO)
        
        XCTAssertNotNil(attendanceModel)
        XCTAssertEqual(attendanceModel?.id, "attendance-1")
        XCTAssertEqual(attendanceModel?.userId, "user-1")
        XCTAssertEqual(attendanceModel?.eventId, "event-1")
        XCTAssertEqual(attendanceModel?.status, .maybe)
        XCTAssertEqual(attendanceModel?.userName, "Test User")
        XCTAssertEqual(attendanceModel?.userEmail, "test@example.com")
        XCTAssertEqual(attendanceModel?.createdAt, dateFormatter.date(from: testDateString))
    }
    
    func testAttendanceMapperToModelWithInvalidStatus() {
        let testDateString = "2024-01-15T10:30:00Z"
        let attendanceDTO = AttendanceDTO(
            id: "attendance-1",
            userId: "user-1",
            eventId: "event-1",
            status: "invalid-status",
            userName: "Test User",
            userEmail: "test@example.com",
            createdAt: testDateString
        )
        
        let attendanceModel = AttendanceMapper.toModel(from: attendanceDTO)
        
        XCTAssertNil(attendanceModel)
    }
    
    func testAttendanceMapperToModelWithInvalidDate() {
        let attendanceDTO = AttendanceDTO(
            id: "attendance-1",
            userId: "user-1",
            eventId: "event-1",
            status: "going",
            userName: "Test User",
            userEmail: "test@example.com",
            createdAt: "invalid-date"
        )
        
        let attendanceModel = AttendanceMapper.toModel(from: attendanceDTO)
        
        XCTAssertNil(attendanceModel)
    }
    
    func testAttendanceMapperToCreateDTO() {
        let attendanceModel = AttendanceModel(
            userId: "user-1",
            eventId: "event-1",
            status: .notGoing,
            userName: "Test User",
            userEmail: "test@example.com"
        )
        
        let createDTO = AttendanceMapper.toCreateDTO(from: attendanceModel)
        
        XCTAssertEqual(createDTO.userId, "user-1")
        XCTAssertEqual(createDTO.eventId, "event-1")
        XCTAssertEqual(createDTO.status, "notGoing")
        XCTAssertEqual(createDTO.userName, "Test User")
        XCTAssertEqual(createDTO.userEmail, "test@example.com")
    }
    
    // MARK: - AttendanceStatus Enum Tests
    
    func testAttendanceStatusRawValues() {
        XCTAssertEqual(AttendanceStatus.going.rawValue, "going")
        XCTAssertEqual(AttendanceStatus.notGoing.rawValue, "notGoing")
        XCTAssertEqual(AttendanceStatus.maybe.rawValue, "maybe")
    }
    
    func testAttendanceStatusFromRawValue() {
        XCTAssertEqual(AttendanceStatus(rawValue: "going"), .going)
        XCTAssertEqual(AttendanceStatus(rawValue: "notGoing"), .notGoing)
        XCTAssertEqual(AttendanceStatus(rawValue: "maybe"), .maybe)
        XCTAssertNil(AttendanceStatus(rawValue: "invalid"))
    }
    
    func testAttendanceStatusDisplayText() {
        XCTAssertEqual(AttendanceStatus.going.displayText, "Asistiré")
        XCTAssertEqual(AttendanceStatus.notGoing.displayText, "No asistiré")
        XCTAssertEqual(AttendanceStatus.maybe.displayText, "Tal vez")
    }
}