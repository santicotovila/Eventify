import SwiftUI

struct EventsRowView: View {
    let event: EventModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(event.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(event.formattedTime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(event.isUpcoming ? .blue : .secondary)
                }
            }
            
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if !event.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(event.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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