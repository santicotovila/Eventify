import Foundation

struct UserDTO: Codable {
    let id: String
    let email: String
    let displayName: String?
    let createdAt: String
    let updatedAt: String
}

struct CreateUserDTO: Codable {
    let email: String
    let displayName: String?
}

struct UpdateUserDTO: Codable {
    let displayName: String?
}