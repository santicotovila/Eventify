import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works server Eventify!"
    }

    try app.group("api") { builder in
        try builder.register(collection: AuthController())
        try builder.register(collection: UsersController())
        try builder.register(collection: InterestsController())
        try builder.register(collection: EventsController())
        try builder.register(collection: EventAttendeesController())
        
    }

    
}
