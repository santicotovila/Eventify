
import Vapor
import Fluent

//Constantes utilizadass para dar mas seguridad y evitar confuciones con los nombres

struct ConstantsEvents {
    static let schemaEvents   = "events"
    static let nameEvent: FieldKey = "nameEvent"
    static let descriptionEvent: FieldKey = "descriptionEvent"
    static let userID: FieldKey = "userID"
    static let category: FieldKey = "category"
    static let createdAt: FieldKey = "created_at"
    static let updatedAt: FieldKey = "updated_at"
    static let eventDate: FieldKey = "eventDate"
    static let lat: FieldKey = "lat"
    static let lng: FieldKey = "lng"
    static let location: FieldKey = "location"
}
