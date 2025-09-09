import Foundation

extension DateFormatter {
    
    /// Formatter para mostrar eventos en formato legible
    /// Ejemplo: "Lunes, 15 de Enero 2024"
    static let eventFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    /// Formatter para mostrar solo la hora
    /// Ejemplo: "18:30"
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    /// Formatter para fecha y hora completa
    /// Ejemplo: "15 Ene 2024, 18:30"
    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
}