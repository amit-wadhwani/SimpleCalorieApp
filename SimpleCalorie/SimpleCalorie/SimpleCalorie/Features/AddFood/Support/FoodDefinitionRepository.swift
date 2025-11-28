import Foundation

/// Repository protocol for food definition data access (search and lookup)
protocol FoodDefinitionRepository {
    /// Search foods by query string
    /// - Parameters:
    ///   - query: Search query (case-insensitive substring match)
    ///   - limit: Maximum number of results to return
    /// - Returns: Array of matching FoodDefinition items
    func searchFoods(query: String, limit: Int) async throws -> [FoodDefinition]
    
    /// Load a specific food by its ID
    /// - Parameter id: UUID of the food
    /// - Returns: FoodDefinition if found
    /// - Throws: FoodDefinitionRepositoryError.notFound if food doesn't exist
    func loadFood(by id: UUID) async throws -> FoodDefinition
}

/// Errors that can occur when accessing food definition repository
enum FoodDefinitionRepositoryError: Error {
    case notFound
    case unavailable
}

/// Configuration mode for food repository
enum FoodRepositoryMode: Hashable {
    case localOnly        // current behavior
    case remoteOnly       // stage 2 option
    case caching          // cache + remote
}

#if DEBUG
/// DEBUG-only helper for persisting FoodRepositoryMode selection
enum FoodRepositoryModeSetting {
    private static let key = "FoodRepositoryModeSetting"
    
    static func current() -> FoodRepositoryMode {
        let stored = UserDefaults.standard.string(forKey: key)
        switch stored {
        case "remoteOnly":
            return .remoteOnly
        case "caching":
            return .caching
        default:
            return .localOnly
        }
    }
    
    static func set(mode: FoodRepositoryMode) {
        let value: String
        switch mode {
        case .localOnly:
            value = "localOnly"
        case .remoteOnly:
            value = "remoteOnly"
        case .caching:
            value = "caching"
        }
        UserDefaults.standard.set(value, forKey: key)
    }
}
#endif

/// Factory for creating food repositories based on mode
struct FoodRepositoryFactory {
    static func makeRepository(mode: FoodRepositoryMode) -> FoodDefinitionRepository {
        switch mode {
        case .localOnly:
            return LocalFoodRepository()
        case .remoteOnly:
            return RemoteFoodRepository()
        case .caching:
            let local = LocalFoodRepository()
            let remote = RemoteFoodRepository()
            return CachingFoodRepository(local: local, remote: remote)
        }
    }
}

