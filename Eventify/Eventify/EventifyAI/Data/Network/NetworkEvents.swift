//
//  NetworkEvents.swift
//  EventifyAI
//
//  Created by Javier Gómez on 14/9/25.
//

import Foundation

// Protocolo para servicios de red de eventos
protocol NetworkEventsProtocol {
    func getEvents(userId: String) async throws -> [EventModel]
    func getEventById(eventId: String) async throws -> EventModel?
    func createEvent(event: EventModel) async throws -> EventModel
    func updateEvent(eventId: String, event: EventModel) async throws -> EventModel
    func deleteEvent(eventId: String) async throws
}

// Servicio de red para eventos - CRUD completo con autenticación JWT
final class NetworkEvents: NetworkEventsProtocol {
    private let session = URLSession.shared
    private let baseURL = ConstantsApp.API.baseURL
    
    // MARK: - Métodos auxiliares privados
    
    // Agregar token JWT a peticiones autenticadas
    private func addAuthHeader(to request: inout URLRequest) {
        if let token = KeyChainEventify.shared.getUserToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    // Estructura que devuelve el backend para eventos
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
    
    // Estructura que espera el backend para crear/actualizar eventos
    private struct BackendEventRequest: Codable {
        let name: String
        let category: String
        let userID: UUID
        let eventDate: Date?
        let location: String
        let lat: Double?
        let lng: Double?
    }
    
    
    // Obtener eventos del usuario - usa fallback por bug en endpoint específico
    func getEvents(userId: String) async throws -> [EventModel] {
        // FALLBACK: usar /api/events y filtrar por userID
        guard let url = URL(string: "\(baseURL)/events") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 else {
                switch httpResponse.statusCode {
                case 400:
                    throw NetworkError.badRequest("IDs mal formados")
                case 401:
                    throw NetworkError.unauthorized
                case 404:
                    throw NetworkError.notFound
                case 500...599:
                    throw NetworkError.internalServerError
                default:
                    if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                        throw NetworkError.requestFailed(responseCode)
                    } else {
                        throw NetworkError.unknown(URLError(.badServerResponse))
                    }
                }
            }
            
            // Respuesta paginada del backend
            struct EventsResponse: Codable {
                let items: [BackendEventResponse]
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let eventsResponse = try decoder.decode(EventsResponse.self, from: data)
            
            // Filtrar por userID y mapear a nuestro modelo
            
            let filteredEvents = eventsResponse.items.filter { $0.userID.uuidString == userId }
            
            return filteredEvents.map { backendEvent in
                EventModel(
                    id: backendEvent.id.uuidString,
                    title: backendEvent.name,
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
            throw NetworkError.decodingError(error)
        }
    }
    
    // Obtener evento específico por ID
    func getEventById(eventId: String) async throws -> EventModel? {
        guard let eventUUID = UUID(uuidString: eventId),
              let url = URL(string: "\(baseURL)/events/\(eventUUID)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
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
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backendEvent = try decoder.decode(BackendEventResponse.self, from: data)
            
            return EventModel(
                id: backendEvent.id.uuidString,
                title: backendEvent.name,
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
            throw NetworkError.decodingError(error)
        }
    }
    
    // Crear nuevo evento en el backend
    func createEvent(event: EventModel) async throws -> EventModel {
        
        guard let url = URL(string: "\(baseURL)/events") else {
            throw NetworkError.invalidURL
        }
        
        // Validar campos requeridos antes de enviar
        guard let originalUserID = event.userID else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        guard let userUUID = UUID(uuidString: originalUserID) else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
        let backendRequest = BackendEventRequest(
            name: event.name ?? event.title,
            category: event.category ?? "general",
            userID: userUUID,
            eventDate: event.date,
            location: event.location,
            lat: event.lat ?? 40.4168,
            lng: event.lng ?? -3.7038
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(backendRequest)
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
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backendEvent = try decoder.decode(BackendEventResponse.self, from: data)
            
            return EventModel(
                id: backendEvent.id.uuidString,
                title: backendEvent.name,
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
            throw NetworkError.decodingError(error)
        }
    }
    
    // Actualizar evento existente
    func updateEvent(eventId: String, event: EventModel) async throws -> EventModel {
        guard let eventUUID = UUID(uuidString: eventId),
              let url = URL(string: "\(baseURL)/events/\(eventUUID)") else {
            throw NetworkError.invalidURL
        }
        
        // Validar campos requeridos para actualización
        guard let userID = event.userID,
              let userUUID = UUID(uuidString: userID) else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.PUT.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
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
                switch httpResponse.statusCode {
                case 400:
                    throw NetworkError.badRequest("IDs mal formados")
                case 401:
                    throw NetworkError.unauthorized
                case 404:
                    throw NetworkError.notFound
                case 500...599:
                    throw NetworkError.internalServerError
                default:
                    if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                        throw NetworkError.requestFailed(responseCode)
                    } else {
                        throw NetworkError.unknown(URLError(.badServerResponse))
                    }
                }
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backendEvent = try decoder.decode(BackendEventResponse.self, from: data)
            
            return EventModel(
                id: backendEvent.id.uuidString,
                title: backendEvent.name,
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
            throw NetworkError.decodingError(error)
        }
    }
    
    // Eliminar evento del backend
    func deleteEvent(eventId: String) async throws {
        guard let eventUUID = UUID(uuidString: eventId),
              let url = URL(string: "\(baseURL)/events/\(eventUUID)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.DELETE.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
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
            throw NetworkError.decodingError(error)
        }
    }
}