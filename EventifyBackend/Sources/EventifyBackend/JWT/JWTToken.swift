import Vapor
import JWT

struct JWTToken: JWTPayload, Authenticatable {
    
    let userID: SubjectClaim
    let username: SubjectClaim
    let expiration: ExpirationClaim
    let isRefresh: BoolClaim       // Útil para indicar si el token es de refresh
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        // Verifica que el token no esté expirado
        try expiration.verifyNotExpired()
    }
}

extension JWTToken {
    
    // Genera un par de tokens (access y refresh) para el usuario en cuestion.
    static func generateTokens(for username: String,andID userID: UUID) -> (accessToken: JWTToken,refreshToken: JWTToken) {
        let now = Date.now
        let tokenExpDate = now.addingTimeInterval(Constants.accessTokenLifetime)
        let refreshExpDate = now.addingTimeInterval(Constants.refreshTokenLifetime)
        
        let accessToken = JWTToken(
            userID: SubjectClaim(value: userID.uuidString),
            username: SubjectClaim(value: username),
            expiration: ExpirationClaim(value: tokenExpDate),
            isRefresh: false
        )
        
        let refreshToken = JWTToken(
            userID: SubjectClaim(value: userID.uuidString),
            username: SubjectClaim(value: username),
            expiration: ExpirationClaim(value: refreshExpDate),
            isRefresh: true
        )
        
        return (accessToken, refreshToken)
    }
}
