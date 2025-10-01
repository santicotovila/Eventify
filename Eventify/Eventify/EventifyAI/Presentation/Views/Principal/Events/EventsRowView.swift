import SwiftUI

struct EventsRowView: View {
    let event: EventModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Imagen/icono del evento
            RoundedRectangle(cornerRadius: 16)
                .fill(getEventColor(for: event.title))
                .frame(width: 50, height: 50)
                .overlay(
                    getEventIcon(for: event.title)
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            // Información del evento
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(formatEventDate(event.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

// Nueva vista para las tarjetas como en las imágenes
struct EventCardView: View {
    let event: EventModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del evento con fondo colorido más estilizado
            RoundedRectangle(cornerRadius: 16)
                .fill(getEventColor(for: event.title))
                .frame(width: 68, height: 68)
                .overlay(
                    getEventIcon(for: event.title)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Información del evento
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 12) {
                    // Fecha con icono
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray.opacity(0.8))
                        
                        Text(formatEventDate(event.date))
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                
                // Ubicación con icono
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.7))
                    
                    Text(event.location)
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Flecha de navegación
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.75, green: 0.78, blue: 0.82))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
    
    // Función para obtener color basado en el tipo de evento
    private func getEventColor(for title: String) -> Color {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return .blue }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return .green }
        if lowercased.contains("picnic") { return .orange }
        if lowercased.contains("room") || lowercased.contains("escape") { return .yellow }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return .red }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return .purple }
        return .blue
    }
    
    // Función para obtener icono basado en el tipo de evento
    private func getEventIcon(for title: String) -> Image {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return Image(systemName: "film") }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return Image(systemName: "tree") }
        if lowercased.contains("picnic") { return Image(systemName: "basket") }
        if lowercased.contains("room") || lowercased.contains("escape") { return Image(systemName: "key") }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return Image(systemName: "wineglass") }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return Image(systemName: "party.popper") }
        return Image(systemName: "calendar")
    }
    
    // Función para formatear la fecha como en la imagen
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        dayFormatter.locale = Locale(identifier: "es_ES")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d 'de' MMMM"
        dateFormatter.locale = Locale(identifier: "es_ES")
        
        let dayOfWeek = dayFormatter.string(from: date).capitalized
        let dateString = dateFormatter.string(from: date)
        
        return "\(dayOfWeek), \(dateString)"
    }
}

extension EventsRowView {
    // Función para obtener color basado en el tipo de evento
    private func getEventColor(for title: String) -> Color {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return .blue }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return .green }
        if lowercased.contains("picnic") { return .orange }
        if lowercased.contains("room") || lowercased.contains("escape") { return .yellow }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return .red }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return .purple }
        return .blue
    }
    
    // Función para obtener icono basado en el tipo de evento
    private func getEventIcon(for title: String) -> Image {
        let lowercased = title.lowercased()
        if lowercased.contains("cine") { return Image(systemName: "film") }
        if lowercased.contains("parque") || lowercased.contains("paseo") { return Image(systemName: "tree") }
        if lowercased.contains("picnic") { return Image(systemName: "basket") }
        if lowercased.contains("room") || lowercased.contains("escape") { return Image(systemName: "key") }
        if lowercased.contains("cañas") || lowercased.contains("bar") { return Image(systemName: "wineglass") }
        if lowercased.contains("fiesta") || lowercased.contains("party") { return Image(systemName: "party.popper") }
        return Image(systemName: "calendar")
    }
    
    // Función para formatear la fecha como en la imagen
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        dayFormatter.locale = Locale(identifier: "es_ES")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d 'de' MMMM"
        dateFormatter.locale = Locale(identifier: "es_ES")
        
        let dayOfWeek = dayFormatter.string(from: date).capitalized
        let dateString = dateFormatter.string(from: date)
        
        return "\(dayOfWeek), \(dateString)"
    }
}

#Preview {
    VStack(spacing: 16) {
        EventsRowView(event: EventModel.preview)
        EventsRowView(event: EventModel.previewPast)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
