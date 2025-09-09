import Foundation

final class DefaultEventsRepository: EventsRepositoryProtocol {
    
    private let networkEvents: NetworkEventsProtocol
    private let keychain: kcPersistenceKeyChain
    
    init(
        networkEvents: NetworkEventsProtocol = NetworkEvents(),
        keychain: kcPersistenceKeyChain = .shared
    ) {
        self.networkEvents = networkEvents
        self.keychain = keychain
    }
    
    func createEvent(_ event: EventModel) async throws -> EventModel {
        do {
            let createdEvent = try await networkEvents.createEvent(event: event)
            NotificationCenter.default.postEventWasCreated(event: createdEvent)
            return createdEvent
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func getEvents(for userId: String) async throws -> [EventModel] {
        do {
            let events = try await networkEvents.getEvents(userId: userId)
            return events
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func getEventById(_ eventId: String) async throws -> EventModel? {
        do {
            let event = try await networkEvents.getEventById(eventId: eventId)
            return event
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func updateEvent(_ event: EventModel) async throws -> EventModel {
        do {
            let updatedEvent = try await networkEvents.updateEvent(eventId: event.id, event: event)
            NotificationCenter.default.postEventWasUpdated(event: updatedEvent)
            return updatedEvent
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func deleteEvent(eventId: String) async throws {
        do {
            try await networkEvents.deleteEvent(eventId: eventId)
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
}