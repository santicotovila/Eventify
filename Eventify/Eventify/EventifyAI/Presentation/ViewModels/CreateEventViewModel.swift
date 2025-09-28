//
//  CreateEventViewModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 12/9/25.
//

import Foundation
import SwiftData

@Observable
final class CreateEventViewModel {
    
    var eventTitle: String = ""
    var eventDescription: String = ""
    var eventLocation: String = ""
    var eventDate: Date = Date().addingTimeInterval(3600)
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isEventCreated: Bool = false
    
    var isFormValid: Bool {
        return !eventTitle.isEmpty && !eventDescription.isEmpty && !eventLocation.isEmpty
    }
    
    @ObservationIgnored
    private var eventsUseCase: EventsUseCaseProtocol
    
    init(eventsUseCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.eventsUseCase = eventsUseCase
    }
    
    // Método para inyectar modelContext después de init
    func setModelContext(_ modelContext: ModelContext) {
        self.eventsUseCase = EventsUseCase(modelContext: modelContext)
    }
    @MainActor
    func createEvent() async {
        isLoading = true
        errorMessage = nil
        
        // Obtener el usuario actual del keychain
        guard let currentUser = KeyChainEventify.shared.getCurrentUser() else {
            errorMessage = "No hay usuario autenticado"
            isLoading = false
            return
        }
        
        // Usar una categoría real del backend (Aprendizaje)
        let defaultCategoryId = "96205784-26B7-45B6-8A1B-7420D81D2808" // Categoría "Aprendizaje" 
        let defaultLatitude = 40.4168 // Madrid por defecto
        let defaultLongitude = -3.7038 // Madrid por defecto
        
        let newEvent = EventModel(
            title: eventTitle,
            description: eventDescription,
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
            NotificationCenter.default.postEventWasCreated(event: newEvent)
        } else {
            errorMessage = "Error al crear el evento"
        }
        
        isLoading = false
    }
}
