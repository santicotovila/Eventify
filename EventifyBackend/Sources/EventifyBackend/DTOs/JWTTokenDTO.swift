import Vapor

//DTO para el token,tanto refresh con Access
struct JWTTokenDTO: Content {
    
    let accessToken: String
    let refreshToken: String
}
