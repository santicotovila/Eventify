import Foundation

// MARK: - Este archivo ya no es necesario con el patrón Factory
// pero lo mantenemos por compatibilidad con otros archivos que puedan usarlo

extension Notification.Name {
    /// Notificación cuando un usuario inicia sesión (DEPRECATED - usar callbacks)
    static let userDidSignIn = Notification.Name("userDidSignIn")
    
    /// Notificación cuando se crea un evento (DEPRECATED - usar callbacks)
    static let eventWasCreated = Notification.Name("eventWasCreated")
}