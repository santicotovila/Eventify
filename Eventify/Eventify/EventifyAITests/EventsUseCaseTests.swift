import XCTest
@testable import EventifyAI

final class EventsUseCaseTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: EventsUseCase!
    private var mockRepository: MockEventsRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockRepository = MockEventsRepository()
        sut = EventsUseCase(repo: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Get Events Tests
    
    func testGetEvents_WithEmptyFilter_ShouldReturnAllEvents() async {
        // Given
        let mockEvents = [
            EventModel(
                title: "Event 1",
                description: "Description 1",
                date: Date(),
                location: "Location 1",
                organizerId: "organizer-1",
                organizerName: "Organizer 1"
            ),
            EventModel(
                title: "Event 2",
                description: "Description 2",
                date: Date(),
                location: "Location 2",
                organizerId: "organizer-2",
                organizerName: "Organizer 2"
            )
        ]
        mockRepository.setMockEvents(mockEvents)
        
        // When
        let result = await sut.getEvents(filter: "")
        
        // Then
        XCTAssertTrue(mockRepository.getEventsCalled)
        XCTAssertEqual(mockRepository.capturedFilter, "")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].title, "Event 1")
        XCTAssertEqual(result[1].title, "Event 2")
    }
    
    func testGetEvents_WithFilter_ShouldReturnFilteredEvents() async {
        // Given
        let mockEvents = [
            EventModel(
                title: "Birthday Party",
                description: "Celebration time",
                date: Date(),
                location: "Home",
                organizerId: "organizer-1",
                organizerName: "Organizer 1"
            ),
            EventModel(
                title: "Work Meeting",
                description: "Team discussion",
                date: Date(),
                location: "Office",
                organizerId: "organizer-2",
                organizerName: "Organizer 2"
            ),
            EventModel(
                title: "Conference",
                description: "Birthday celebration of the company",
                date: Date(),
                location: "Convention Center",
                organizerId: "organizer-3",
                organizerName: "Organizer 3"
            )
        ]
        mockRepository.setMockEvents(mockEvents)
        
        // When
        let result = await sut.getEvents(filter: "birthday")
        
        // Then
        XCTAssertTrue(mockRepository.getEventsCalled)
        XCTAssertEqual(mockRepository.capturedFilter, "birthday")
        XCTAssertEqual(result.count, 2) // "Birthday Party" and "Conference" (description contains "birthday")
        XCTAssertTrue(result.contains { $0.title == "Birthday Party" })
        XCTAssertTrue(result.contains { $0.title == "Conference" })
    }
    
    func testGetEvents_WithNoMatchingFilter_ShouldReturnEmptyArray() async {
        // Given
        let mockEvents = [
            EventModel(
                title: "Event 1",
                description: "Description 1",
                date: Date(),
                location: "Location 1",
                organizerId: "organizer-1",
                organizerName: "Organizer 1"
            )
        ]
        mockRepository.setMockEvents(mockEvents)
        
        // When
        let result = await sut.getEvents(filter: "nonexistent")
        
        // Then
        XCTAssertTrue(mockRepository.getEventsCalled)
        XCTAssertEqual(mockRepository.capturedFilter, "nonexistent")
        XCTAssertTrue(result.isEmpty)
    }
    
    // MARK: - Create Event Tests
    
    func testCreateEvent_WithValidEvent_ShouldReturnTrue() async {
        // Given
        let event = EventModel(
            title: "New Event",
            description: "New Description",
            date: Date().addingTimeInterval(3600), // 1 hour in future
            location: "New Location",
            organizerId: "organizer-123",
            organizerName: "New Organizer"
        )
        mockRepository.setCreateEventResult(true)
        
        // When
        let result = await sut.createEvent(event)
        
        // Then
        XCTAssertTrue(mockRepository.createEventCalled)
        XCTAssertEqual(mockRepository.capturedEvent?.title, event.title)
        XCTAssertEqual(mockRepository.capturedEvent?.description, event.description)
        XCTAssertEqual(mockRepository.capturedEvent?.location, event.location)
        XCTAssertEqual(mockRepository.capturedEvent?.organizerId, event.organizerId)
        XCTAssertTrue(result)
    }
    
    func testCreateEvent_WithRepositoryFailure_ShouldReturnFalse() async {
        // Given
        let event = EventModel(
            title: "Failed Event",
            description: "This will fail",
            date: Date(),
            location: "Nowhere",
            organizerId: "organizer-456",
            organizerName: "Failed Organizer"
        )
        mockRepository.setCreateEventResult(false)
        
        // When
        let result = await sut.createEvent(event)
        
        // Then
        XCTAssertTrue(mockRepository.createEventCalled)
        XCTAssertEqual(mockRepository.capturedEvent?.title, event.title)
        XCTAssertFalse(result)
    }
    
    func testCreateEvent_ShouldAddEventToRepository() async {
        // Given
        let initialEvents = [
            EventModel(
                title: "Existing Event",
                description: "Existing Description",
                date: Date(),
                location: "Existing Location",
                organizerId: "organizer-1",
                organizerName: "Existing Organizer"
            )
        ]
        mockRepository.setMockEvents(initialEvents)
        
        let newEvent = EventModel(
            title: "New Event",
            description: "New Description",
            date: Date(),
            location: "New Location",
            organizerId: "organizer-2",
            organizerName: "New Organizer"
        )
        mockRepository.setCreateEventResult(true)
        
        // When
        let createResult = await sut.createEvent(newEvent)
        let allEvents = await sut.getEvents(filter: "")
        
        // Then
        XCTAssertTrue(createResult)
        XCTAssertEqual(allEvents.count, 2)
        XCTAssertTrue(allEvents.contains { $0.title == "Existing Event" })
        XCTAssertTrue(allEvents.contains { $0.title == "New Event" })
    }
    
    // MARK: - Delete Event Tests
    
    func testDeleteEvent_WithValidEventId_ShouldReturnTrue() async {
        // Given
        let eventId = "event-to-delete"
        mockRepository.setDeleteEventResult(true)
        
        // When
        let result = await sut.deleteEvent(eventId)
        
        // Then
        XCTAssertTrue(mockRepository.deleteEventCalled)
        XCTAssertEqual(mockRepository.capturedEventId, eventId)
        XCTAssertTrue(result)
    }
    
    func testDeleteEvent_WithRepositoryFailure_ShouldReturnFalse() async {
        // Given
        let eventId = "nonexistent-event"
        mockRepository.setDeleteEventResult(false)
        
        // When
        let result = await sut.deleteEvent(eventId)
        
        // Then
        XCTAssertTrue(mockRepository.deleteEventCalled)
        XCTAssertEqual(mockRepository.capturedEventId, eventId)
        XCTAssertFalse(result)
    }
    
    func testDeleteEvent_ShouldRemoveEventFromRepository() async {
        // Given
        let eventToKeep = EventModel(
            id: "keep-event",
            title: "Keep Event",
            description: "This event should remain",
            date: Date(),
            location: "Keep Location",
            organizerId: "organizer-1",
            organizerName: "Keep Organizer"
        )
        
        let eventToDelete = EventModel(
            id: "delete-event",
            title: "Delete Event",
            description: "This event should be deleted",
            date: Date(),
            location: "Delete Location",
            organizerId: "organizer-2",
            organizerName: "Delete Organizer"
        )
        
        mockRepository.setMockEvents([eventToKeep, eventToDelete])
        mockRepository.setDeleteEventResult(true)
        
        // When
        let deleteResult = await sut.deleteEvent("delete-event")
        let remainingEvents = await sut.getEvents(filter: "")
        
        // Then
        XCTAssertTrue(deleteResult)
        XCTAssertEqual(remainingEvents.count, 1)
        XCTAssertEqual(remainingEvents.first?.id, "keep-event")
        XCTAssertFalse(remainingEvents.contains { $0.id == "delete-event" })
    }
    
    // MARK: - Integration Tests
    
    func testCreateAndRetrieveEvent_ShouldWorkTogether() async {
        // Given
        let event = EventModel(
            title: "Integration Test Event",
            description: "Testing create and retrieve",
            date: Date(),
            location: "Test Location",
            organizerId: "test-organizer",
            organizerName: "Test Organizer"
        )
        mockRepository.setCreateEventResult(true)
        
        // When
        let createResult = await sut.createEvent(event)
        let retrievedEvents = await sut.getEvents(filter: "Integration")
        
        // Then
        XCTAssertTrue(createResult)
        XCTAssertEqual(retrievedEvents.count, 1)
        XCTAssertEqual(retrievedEvents.first?.title, "Integration Test Event")
    }
    
    func testCreateDeleteAndRetrieve_ShouldWorkTogether() async {
        // Given
        let event = EventModel(
            id: "integration-event",
            title: "Integration Event",
            description: "For testing",
            date: Date(),
            location: "Test Location",
            organizerId: "test-organizer",
            organizerName: "Test Organizer"
        )
        mockRepository.setCreateEventResult(true)
        mockRepository.setDeleteEventResult(true)
        
        // When
        let createResult = await sut.createEvent(event)
        let eventsAfterCreate = await sut.getEvents(filter: "")
        let deleteResult = await sut.deleteEvent("integration-event")
        let eventsAfterDelete = await sut.getEvents(filter: "")
        
        // Then
        XCTAssertTrue(createResult)
        XCTAssertEqual(eventsAfterCreate.count, 1)
        XCTAssertTrue(deleteResult)
        XCTAssertTrue(eventsAfterDelete.isEmpty)
    }
}