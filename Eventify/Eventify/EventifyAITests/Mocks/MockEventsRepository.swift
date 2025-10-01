import Foundation
@testable import EventifyAI

final class MockEventsRepository: EventsRepositoryProtocol {
    
    // MARK: - Test Control Properties
    var getEventsCalled = false
    var createEventCalled = false
    var deleteEventCalled = false
    
    // MARK: - Configurable Results
    var getEventsResult: [EventModel] = []
    var createEventResult: Bool = true
    var deleteEventResult: Bool = true
    
    // MARK: - Captured Parameters
    var capturedFilter: String?
    var capturedEvent: EventModel?
    var capturedEventId: String?
    
    // MARK: - Protocol Implementation
    
    func getEvents(filter: String) async -> [EventModel] {
        getEventsCalled = true
        capturedFilter = filter
        
        if filter.isEmpty {
            return getEventsResult
        } else {
            return getEventsResult.filter { event in
                event.title.lowercased().contains(filter.lowercased()) ||
                event.description.lowercased().contains(filter.lowercased()) ||
                event.location.lowercased().contains(filter.lowercased())
            }
        }
    }
    
    func createEvent(_ event: EventModel) async -> Bool {
        createEventCalled = true
        capturedEvent = event
        
        if createEventResult {
            // Add to the mock events list if successful
            getEventsResult.append(event)
        }
        
        return createEventResult
    }
    
    func deleteEvent(_ eventId: String) async -> Bool {
        deleteEventCalled = true
        capturedEventId = eventId
        
        if deleteEventResult {
            // Remove from the mock events list if successful
            getEventsResult.removeAll { $0.id == eventId }
        }
        
        return deleteEventResult
    }
    
    // MARK: - Test Helper Methods
    
    func reset() {
        getEventsCalled = false
        createEventCalled = false
        deleteEventCalled = false
        
        getEventsResult = []
        createEventResult = true
        deleteEventResult = true
        
        capturedFilter = nil
        capturedEvent = nil
        capturedEventId = nil
    }
    
    func setMockEvents(_ events: [EventModel]) {
        getEventsResult = events
    }
    
    func setCreateEventResult(_ result: Bool) {
        createEventResult = result
    }
    
    func setDeleteEventResult(_ result: Bool) {
        deleteEventResult = result
    }
    
    func addMockEvent(_ event: EventModel) {
        getEventsResult.append(event)
    }
}