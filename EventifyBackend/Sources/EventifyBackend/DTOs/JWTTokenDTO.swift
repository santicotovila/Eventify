import Vapor

struct JWTTokenDTO: Content {
    
    let accessToken: String
    let refreshToken: String
}

