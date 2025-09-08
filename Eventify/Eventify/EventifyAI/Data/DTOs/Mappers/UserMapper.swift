import Foundation

struct UserMapper {
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    static func toModel(from dto: UserDTO) -> UserModel? {
        guard let createdAt = dateFormatter.date(from: dto.createdAt),
              let updatedAt = dateFormatter.date(from: dto.updatedAt) else {
            return nil
        }
        
        return UserModel(
            id: dto.id,
            email: dto.email,
            displayName: dto.displayName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func toDTO(from model: UserModel) -> UserDTO {
        return UserDTO(
            id: model.id,
            email: model.email,
            displayName: model.displayName,
            createdAt: dateFormatter.string(from: model.createdAt),
            updatedAt: dateFormatter.string(from: model.updatedAt)
        )
    }
    
    static func toCreateDTO(from model: UserModel) -> CreateUserDTO {
        return CreateUserDTO(
            email: model.email,
            displayName: model.displayName
        )
    }
}