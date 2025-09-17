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
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
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

#Preview {
    VStack(spacing: 16) {
        EventsRowView(event: EventModel.preview)
        EventsRowView(event: EventModel.previewPast)
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}