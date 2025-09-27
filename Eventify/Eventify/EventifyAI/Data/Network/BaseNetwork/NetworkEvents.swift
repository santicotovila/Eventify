//
//  NetworkEvents.swift
//  EventifyAI
//
//  Created by Javier Gómez on 14/9/25.
//

import Foundation

protocol NetworkEventsProtocol {
    func getEvents(userId: String) async throws -> [EventModel]
    func getEventById(eventId: String) async throws -> EventModel?
    func createEvent(event: EventModel) async throws -> EventModel
    func updateEvent(eventId: String, event: EventModel) async throws -> EventModel
    func deleteEvent(eventId: String) async throws
}

final class NetworkEvents: NetworkEventsProtocol {
    private let session = URLSession.shared
    private let baseURL = "http://localhost:8080/api" // URL del backend
    
    private struct BackendEventResponse: Codable {
        let id: UUID
        let name: String
        let category: String
        let lat: Double?
        let lng: Double?
        let userID: UUID
        let createdAt: Date?
        let updatedAt: Date?
        let eventDate: Date?
        let location: String?
    }
    
    private struct BackendEventRequest: Codable {
        let name: String
        let category: String
        let userID: UUID
        let eventDate: Date?
        let location: String
        let lat: Double?
        let lng: Double?
    }
    
    
    func getEvents(userId: String) async throws -> [EventModel] {
        guard let userUUID = UUID(uuidString: userId),
              let url = URL(string: "\(baseURL)/users/\(userUUID)/events") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            let backendEvents = try JSONDecoder().decode([BackendEventResponse].self, from: data)
            
            // Convertir a nuestro modelo EventModel
            return backendEvents.map { backendEvent in
                EventModel(
                    id: backendEvent.id.uuidString,
                    title: backendEvent.name,
                    description: "Descripción del evento",
                    date: backendEvent.eventDate ?? backendEvent.createdAt ?? Date(),
                    location: backendEvent.location ?? "Ubicación no especificada",
                    organizerId: backendEvent.userID.uuidString,
                    organizerName: "Usuario",
                    userID: backendEvent.userID.uuidString,
                    category: backendEvent.category,
                    lat: backendEvent.lat,
                    lng: backendEvent.lng
                )
            }
            
        } catch {
            print("Error fetching events: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
    
    func getEventById(eventId: String) async throws -> EventModel? {
        guard let eventUUID = UUID(uuidString: eventId),
              let url = URL(string: "\(baseURL)/events/\(eventUUID)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 404 {
                    return nil
                }
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            let backendEvent = try JSONDecoder().decode(BackendEventResponse.self, from: data)
            
            return EventModel(
                id: backendEvent.id.uuidString,
                title: backendEvent.name,
                description: "Descripción del evento",
                date: backendEvent.eventDate ?? backendEvent.createdAt ?? Date(),
                location: backendEvent.location ?? "Ubicación no especificada",
                organizerId: backendEvent.userID.uuidString,
                organizerName: "Usuario",
                userID: backendEvent.userID.uuidString,
                category: backendEvent.category,
                lat: backendEvent.lat,
                lng: backendEvent.lng
            )
            
        } catch {
            print("Error fetching event: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
    
    func createEvent(event: EventModel) async throws -> EventModel {
        guard let url = URL(string: "\(baseURL)/events") else {
            throw NetworkError.invalidURL
        }
        
        // Validar que tenemos los campos requeridos
        guard let userID = event.userID,
              let userUUID = UUID(uuidString: userID) else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let backendRequest = BackendEventRequest(
            name: event.name ?? event.title,
            category: event.category ?? "general",
            userID: userUUID,
            eventDate: event.date,
            location: event.location,
            lat: event.lat,
            lng: event.lng
        )
        
        do {
            let jsonData = try JSONEncoder().encode(backendRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            let backendEvent = try JSONDecoder().decode(BackendEventResponse.self, from: data)
            
            return EventModel(
                id: backendEvent.id.uuidString,
                title: backendEvent.name,
                description: event.description,
                date: backendEvent.eventDate ?? backendEvent.createdAt ?? Date(),
                location: backendEvent.location ?? event.location,
                organizerId: backendEvent.userID.uuidString,
                organizerName: event.organizerName,
                userID: backendEvent.userID.uuidString,
                category: backendEvent.category,
                lat: backendEvent.lat,
                lng: backendEvent.lng
            )
            
        } catch {
            print("Error creating event: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
    
    func updateEvent(eventId: String, event: EventModel) async throws -> EventModel {
        guard let eventUUID = UUID(uuidString: eventId),
              let url = URL(string: "\(baseURL)/events/\(eventUUID)") else {
            throw NetworkError.invalidURL
        }
        
        // Validar campos requeridos
        guard let userID = event.userID,
              let userUUID = UUID(uuidString: userID) else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.PUT.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let backendRequest = BackendEventRequest(
            name: event.name ?? event.title,
            category: event.category ?? "general",
            userID: userUUID,
            eventDate: event.date,
            location: event.location,
            lat: event.lat,
            lng: event.lng
        )
        
        do {
            let jsonData = try JSONEncoder().encode(backendRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            let backendEvent = try JSONDecoder().decode(BackendEventResponse.self, from: data)
            
            return EventModel(
                id: backendEvent.id.uuidString,
                title: backendEvent.name,
                description: event.description,
                date: backendEvent.eventDate ?? backendEvent.updatedAt ?? Date(),
                location: backendEvent.location ?? event.location,
                organizerId: backendEvent.userID.uuidString,
                organizerName: event.organizerName,
                userID: backendEvent.userID.uuidString,
                category: backendEvent.category,
                lat: backendEvent.lat,
                lng: backendEvent.lng
            )
            
        } catch {
            print("Error updating event: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
    
    func deleteEvent(eventId: String) async throws {
        guard let eventUUID = UUID(uuidString: eventId),
              let url = URL(string: "\(baseURL)/events/\(eventUUID)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.DELETE.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
        } catch {
            print("Error deleting event: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}