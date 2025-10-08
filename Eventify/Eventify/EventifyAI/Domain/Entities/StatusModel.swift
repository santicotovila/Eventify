import Foundation


enum StatusModel {
    case success
    case loading
    case error(String)
    case none
}

// Extension para comparar estados
extension StatusModel: Equatable {
    static func == (lhs: StatusModel, rhs: StatusModel) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.loading, .loading):
            return true
        case (.none, .none):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
