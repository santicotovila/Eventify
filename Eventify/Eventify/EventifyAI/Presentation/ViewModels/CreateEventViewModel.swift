//
//  CreateEventViewModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 12/9/25.
//

import Foundation
import SwiftData

// ViewModel para crear eventos
@Observable
final class CreateEventViewModel {
    
    // Properties del formulario
    var eventTitle: String = ""
    var eventDescription: String = ""
    var eventLocation: String = ""
    var eventDate: Date = Date().addingTimeInterval(3600)  // 1 hora en el futuro por defecto
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isEventCreated: Bool = false
    
    // Validación del formulario
    var isFormValid: Bool {
        return !eventTitle.isEmpty && !eventDescription.isEmpty && !eventLocation.isEmpty
    }
    
    // @ObservationIgnored evita que SwiftUI observe esta property
    @ObservationIgnored
    private var eventsUseCase: EventsUseCaseProtocol
    
    init(eventsUseCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.eventsUseCase = eventsUseCase
    }
    
    // Para SwiftData - se inyecta el contexto después
    func setModelContext(_ modelContext: ModelContext) {
        self.eventsUseCase = EventsUseCase(modelContext: modelContext)
    }
    @MainActor
    func createEvent() async {
        isLoading = true
        errorMessage = nil
        
        // Obtener el usuario logueado del keychain
        guard let currentUser = KeyChainEventify.shared.getCurrentUser() else {
            errorMessage = "No hay usuario autenticado"
            isLoading = false
            return
        }
        
        // Valores por defecto para el backend
        let defaultCategoryId = "96205784-26B7-45B6-8A1B-7420D81D2808" // Categoría "Aprendizaje" 
        let defaultLatitude = 40.4168   // Madrid
        let defaultLongitude = -3.7038  // Madrid
        
        let newEvent = EventModel(
            title: eventTitle,
            date: eventDate,
            location: eventLocation,
            organizerId: currentUser.id,
            organizerName: currentUser.displayName ?? "Usuario",
            userID: currentUser.id,
            category: defaultCategoryId,
            lat: defaultLatitude,
            lng: defaultLongitude
        )
        
        let success = await eventsUseCase.createEvent(newEvent)
        
        if success {
            isEventCreated = true
            // Notificación para actualizar otras pantallas
            NotificationCenter.default.postEventWasCreated(event: newEvent)
        } else {
            errorMessage = "Error al crear el evento"
        }
        
        isLoading = false
    }
}
