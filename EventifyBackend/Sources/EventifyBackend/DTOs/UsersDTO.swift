import Fluent
import Vapor

struct UsersDTO: Content {
    
    struct Create: Content {
        let name: String
        let email: String
        let password: String
        let interests: [String]
        
        
        func toModel(withHashedPassword hashedPassword: String) -> Users {
            Users(
                name: self.name,
                email: self.email,
                password: hashedPassword,
                interests: self.interests
            )
            
        }
    }
    
    struct Public: Content {
        let id: UUID?
        let name: String
        let email: String
    }
    
    struct Detail: Content {
        let id: UUID?
        let name: String
        let email: String
        let interests: [String]
    }
}
    
extension UsersDTO.Create: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name",as: String.self,is: .count(3...30),required: true)
        validations.add("email",as: String.self, is: .count(5...40) && .email, required: true)
        validations.add("password",as: String.self,is: .count(8...16) && .alphanumeric, required: true)
        validations.add("interests", as: [String].self,is: .count(3...6), required: true)
        
    }
    
    }

extension Users {
    func toPublicDTO() -> UsersDTO.Public {
        UsersDTO.Public(
            id: self.id,
            name: self.name,
            email: self.email
        )
    }
}


extension Users {
    struct Public: Content {
        let id: UUID?
        let name: String
        let email: String
        let isAdmin: Bool
        let interests: [String]?
        let lat: Double?
        let lng: Double?
        let createdAt: Date?
        let updatedAt: Date?
    }

    func toPublic() -> Public {
        Public(
            id: id,
            name: name,
            email: email,
            isAdmin: isAdmin,
            interests: interests,
            lat: lat,
            lng: lng,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
