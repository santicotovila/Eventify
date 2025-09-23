import Foundation

protocol EventsRepositoryProtocol {
    func getEvents(filter: String) async -> [EventModel]
    func createEvent(_ event: EventModel) async -> Bool
}