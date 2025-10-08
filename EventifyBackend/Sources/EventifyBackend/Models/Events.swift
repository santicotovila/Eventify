

import Fluent
import Vapor



// Modelo que representa un evento
// Cada instancia es la relación usuario → evento, con su estado,fecha,categoria,direccion...etc
final class Events: Model, @unchecked Sendable {
    static let schema = ConstantsEvents.schemaEvents
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ConstantsEvents.nameEvent)
    var name: String
    
    @Field(key: ConstantsEvents.category)
    var category: String?
    
    @Field(key: ConstantsEvents.lat)// No esta implementado en el Front todavia por eso utilizamos location
    var lat: Double?
    
    @Field(key: ConstantsEvents.lng)// No esta implementado en el Front todavia por eso utilizamos location
    var lng: Double?
    
    @Parent(key: ConstantsEvents.userID)
    var user: Users
    
    @Field(key: ConstantsEvents.eventDate)
    var eventDate: Date?
    
    @Field(key: ConstantsEvents.location)
    var location: String? //Creación en el ultimo momento porque no daba tiempo a implementar el maps,por lo cual para poder crear eventos por nombre y no por ubicación
    
    @Timestamp(key: ConstantsEvents.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: ConstantsEvents.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() {}
    
    
    init(name:String, category:String? = nil,userID:UUID,lat:Double? = nil ,lng:Double? = nil, eventDate: Date? = nil, location: String? = nil) {
        self.name = name
        self.category = category
        self.$user.id = userID
        self.eventDate = eventDate
        self.location = location
        self.lat = lat
        self.lng = lng
    }
}





