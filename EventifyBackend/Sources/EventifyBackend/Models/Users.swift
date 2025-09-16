import Fluent
import Vapor

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
        self.email = email
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
    
}



