import Foundation

/// Estados de carga para manejar operaciones asíncronas en la UI
/// Utiliza genéricos para ser reutilizable con cualquier tipo de datos
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
    
    /// Indica si está en estado de carga
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    /// Indica si la operación fue exitosa
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    /// Indica si hubo un error
    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }
    
    /// Obtiene los datos si la operación fue exitosa
    var data: T? {
        if case .success(let data) = self {
            return data
        }
        return nil
    }
    
    /// Obtiene el error si la operación falló
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}