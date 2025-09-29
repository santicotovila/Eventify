import Fluent
import Vapor


//Modelo para la creación de usuario
final class Users: Model, @unchecked Sendable {
    static let schema = ConstantsUsers.schemaUsers
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ConstantsUsers.name)
    var name: String
    
    @Field(key: ConstantsUsers.email)
    var email: String
    
    @Field(key: ConstantsUsers.password)
    var password: String
    
    @Field(key: ConstantsUsers.isAdmin)
    var isAdmin: Bool
    
    @Field(key: ConstantsUsers.interests)
    var interests: [String]
    
    @Field(key: ConstantsUsers.lat)
    var lat: Double?
    
    @Field(key: ConstantsUsers.lng)
    var lng: Double?
    
    @Timestamp(key: ConstantsUsers.createdAt, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: ConstantsUsers.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() {}
    
    
    init(name:String, email:String, password:String,interests: [String],isAdmin:Bool = false) {
        self.name = name
        self.email = email.lowercased()
        self.password = password
        self.interests = interests
        self.isAdmin = isAdmin
    }
}


extension Users: ModelAuthenticatable {
   
    
    static var usernameKey: KeyPath<Users, Field<String>> {
        \Users.$email
    }
    
    static var passwordHashKey: KeyPath<Users, Field<String>> {
        \Users.$password
    }

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
    
    
    // Creación de este metodo ya que tenia problemas cuando el usuario utilizaba letras en mayuscula para registrar el usuario,asi me evito de conflictos cuando quiero acceder a la base de datos  teniendo todo bien en minusculas.
    static func authenticate(username: String, password: String, using db: any Database) async throws -> Users? {
            let normalized = username.lowercased()
            guard let user = try await Users.query(on: db)
                .filter(\.$email == normalized)
                .first()
            else { return nil }

            return try user.verify(password: password) ? user : nil
        }
}



