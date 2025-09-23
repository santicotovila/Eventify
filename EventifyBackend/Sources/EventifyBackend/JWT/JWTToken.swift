import Vapor
import JWT

struct JWTToken: JWTPayload, Authenticatable {
    
    let userID: SubjectClaim
    let username: SubjectClaim
    let expiration: ExpirationClaim
    let isRefresh: BoolClaim
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}

extension JWTToken {
    
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
