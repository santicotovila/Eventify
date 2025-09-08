//
// EventsViewModel.swift
// EventifyAI
//
// Nota para los compis del bootcamp:
//
// Este es el ViewModel para nuestra pantalla principal, la que lista los eventos.
// Su trabajo es:
// 1. Pedir los eventos al `EventsUseCase`.
// 2. Separar los eventos en "próximos" y "pasados".
// 3. Gestionar el estado de carga y los posibles errores.
// 4. Escuchar notificaciones para recargar la lista automáticamente si un evento cambia.
//

import Foundation
import Combine

@MainActor
final class EventsViewModel: ObservableObject {
    
    // MARK: - Propiedades para la Vista
    
    @Published var upcomingEvents: [EventModel] = [] // Lista de eventos que aún no han ocurrido.
    @Published var pastEvents: [EventModel] = [] // Lista de eventos que ya pasaron.
    @Published var isLoading: Bool = false // Para mostrar un loader mientras cargamos los datos.
    @Published var errorMessage: String? = nil // Para mostrar un mensaje de error si algo falla.
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var searchText: String = ""
    
    // MARK: - Dependencias
    
    private let eventsUseCase: EventsUseCaseProtocol // El que sabe CÓMO obtener los eventos.
    private let loginUseCase: LoginUseCaseProtocol // Lo necesitamos para saber quién es el usuario actual.
    private var cancellables = Set<AnyCancellable>() // La "bolsa" para nuestras suscripciones de Combine.
    
    // MARK: - Inicializador
    
    init(eventsUseCase: EventsUseCaseProtocol, loginUseCase: LoginUseCaseProtocol) {
        self.eventsUseCase = eventsUseCase
        self.loginUseCase = loginUseCase
        // Configuramos los "oyentes" en cuanto se crea el objeto.
        setupSubscribers()
    }
    
    // MARK: - Lógica Principal
    
    // Carga todos los eventos del usuario actual desde el UseCase.
    func loadAllEvents() async {
        // Primero, nos aseguramos de que hay un usuario logueado.
        guard let currentUser = loginUseCase.getCurrentUser() else {
            errorMessage = "Usuario no autenticado."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Pedimos la lista completa de eventos.
            let allEvents = try await eventsUseCase.getEvents(for: currentUser.id)
            let now = Date()
            
            // Filtramos y ordenamos los eventos en dos listas separadas.
            self.upcomingEvents = allEvents.filter { $0.date > now }.sorted { $0.date < $1.date } // Próximos, ordenados del más cercano al más lejano.
            self.pastEvents = allEvents.filter { $0.date <= now }.sorted { $0.date > $1.date } // Pasados, ordenados del más reciente al más antiguo.
            
        } catch {
            errorMessage = "Error al cargar eventos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Suscripciones a Notificaciones
    
    // Este método hace que nuestra UI sea reactiva y se sienta "viva".
    private func setupSubscribers() {
        // Escuchamos la notificación de que un nuevo evento fue creado.
        NotificationCenter.default.eventWasCreatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Cuando se crea un evento, no necesitamos que nos pasen el evento.
                // Simplemente volvemos a cargar toda la lista para que aparezca.
                Task {
                    await self?.loadAllEvents()
                }
            }
            .store(in: &cancellables)
        
        // Hacemos lo mismo para cuando un evento se actualiza.
        NotificationCenter.default.eventWasUpdatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadAllEvents()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Métodos de Conveniencia
    
    var events: [EventModel] {
        return upcomingEvents + pastEvents
    }
    
    func dismissAlert() {
        showAlert = false
        alertMessage = ""
    }
    
    func refreshEvents() async {
        await loadAllEvents()
    }
    
    func loadEvents() async {
        await loadAllEvents()
    }
    
    private func showAlertMessage(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}