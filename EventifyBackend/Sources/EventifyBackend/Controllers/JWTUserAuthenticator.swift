import Vapor
import JWT
import Fluent

struct JWTUserAuthenticator: AsyncBearerAuthenticator {
    typealias User = Users

    func authenticate(bearer: BearerAuthorization, for req: Request) async throws {
        do {
            let payload = try await req.jwt.verify(bearer.token, as: JWTToken.self)
            guard let userID = UUID(payload.userID.value) else { return }
            if let user = try await Users.find(userID, on: req.db) {
                req.auth.login(user)
            }
        } catch {
            // Silencioso: no autentica si el token es inválido/expirado
        }
    }
}
