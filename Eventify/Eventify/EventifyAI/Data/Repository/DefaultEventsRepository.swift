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
            let createDTO = EventMapper.toCreateDTO(from: event)
            let createdEventDTO = try await networkEvents.createEvent(event: createDTO)
            guard let createdEvent = EventMapper.toModel(from: createdEventDTO) else {
                throw DomainError.mappingFailed("No se pudo convertir EventDTO a EventModel")
            }
            NotificationCenter.default.postEventWasCreated(event: createdEvent)
            return createdEvent
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch let domainError as DomainError {
            throw domainError
        } catch {
            throw EventError.eventCreationFailed(error.localizedDescription)
        }
    }
    
    func getEvents(for userId: String) async throws -> [EventModel] {
        do {
            let eventDTOs = try await networkEvents.getEvents(userId: userId)
            let events = eventDTOs.compactMap { EventMapper.toModel(from: $0) }
            return events
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func getEventById(_ id: String) async throws -> EventModel? {
        do {
            guard let eventDTO = try await networkEvents.getEventById(eventId: id) else {
                return nil
            }
            return EventMapper.toModel(from: eventDTO)
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.unknown(error)
        }
    }
    
    func updateEvent(_ event: EventModel) async throws -> EventModel {
        do {
            let updateDTO = EventMapper.toDTO(from: event)
            let updatedEventDTO = try await networkEvents.updateEvent(eventId: event.id, event: updateDTO)
            guard let updatedEvent = EventMapper.toModel(from: updatedEventDTO) else {
                throw DomainError.mappingFailed("No se pudo convertir EventDTO a EventModel")
            }
            NotificationCenter.default.postEventWasUpdated(event: updatedEvent)
            return updatedEvent
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch let domainError as DomainError {
            throw domainError
        } catch {
            throw EventError.eventUpdateFailed(error.localizedDescription)
        }
    }
    
    func deleteEvent(eventId: String) async throws {
        do {
            try await networkEvents.deleteEvent(eventId: eventId)
        } catch let networkError as NetworkError {
            throw EventError.networkError(networkError)
        } catch {
            throw EventError.eventDeletionFailed(error.localizedDescription)
        }
    }
    
    private func getCurrentUserId() -> String? {
        return keychain.getString(key: ConstantsApp.Keychain.currentUserId)
    }
}

