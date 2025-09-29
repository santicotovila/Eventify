import Foundation
import Vapor
import Fluent

//Constantes utilizadass para dar mas seguridad y evitar confuciones con los nombres
struct ConstantsUsers {
    static let schemaUsers = "users"
    static let name: FieldKey = "name"
    static let email: FieldKey = "email"
    static let password: FieldKey = "password"
    static let isAdmin: FieldKey = "isAdmin"
    static let createdAt: FieldKey = "created_at"
    static let updatedAt: FieldKey = "updated_at"
    static let interests: FieldKey = "interests"
    static let lat: FieldKey = "lat"
    static let lng: FieldKey = "lng"
}
