import Vapor
import JWT
import Fluent

struct JWTUserAuthenticator: AsyncBearerAuthenticator {
    typealias User = Users
    
//Verificamos el token y buscamos usuario en base de datos,si se encuentra,loguea en la request
    func authenticate(bearer: BearerAuthorization, for req: Request) async throws {
        do {
            let payload = try await req.jwt.verify(bearer.token, as: JWTToken.self)
            guard let userID = UUID(payload.userID.value) else { return }
            if let user = try await Users.find(userID, on: req.db) {
                req.auth.login(user)
            }
        } catch {
                    }
    }
}
