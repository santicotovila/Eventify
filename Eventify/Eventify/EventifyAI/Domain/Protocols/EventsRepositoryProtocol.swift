import Foundation

protocol EventsRepositoryProtocol {
    func createEvent(_ event: EventModel) async throws -> EventModel
    func getEvents(for userId: String) async throws -> [EventModel]
    func getEventById(_ id: String) async throws -> EventModel?
    func updateEvent(_ event: EventModel) async throws -> EventModel
    func deleteEvent(eventId: String) async throws
}