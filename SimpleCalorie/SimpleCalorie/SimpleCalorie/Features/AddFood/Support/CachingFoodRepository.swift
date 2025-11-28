import Foundation

/// Caching food repository that combines local and remote sources
final class CachingFoodRepository: FoodDefinitionRepository {
    private let local: FoodDefinitionRepository
    private let remote: FoodDefinitionRepository
    
    // Simple in-memory cache keyed by id for now.
    private var cacheById: [UUID: FoodDefinition] = [:]
    
    init(local: FoodDefinitionRepository, remote: FoodDefinitionRepository) {
        self.local = local
        self.remote = remote
    }
    
    func searchFoods(query: String, limit: Int) async throws -> [FoodDefinition] {
        // Simple staged behavior:
        // 1) Try local
        let localResults = try await local.searchFoods(query: query, limit: limit)
        if !localResults.isEmpty {
            // Cache by id for future loadFood(by:)
            localResults.forEach { cacheById[$0.id] = $0 }
            return localResults
        }
        
        // 2) Try remote (stubbed for now; will be fleshed out in Stage 2)
        let remoteResults = try await remote.searchFoods(query: query, limit: limit)
        remoteResults.forEach { cacheById[$0.id] = $0 }
        return remoteResults
    }
    
    func loadFood(by id: UUID) async throws -> FoodDefinition {
        if let cached = cacheById[id] {
            return cached
        }
        
        // First try local
        if let localFood = try? await local.loadFood(by: id) {
            cacheById[id] = localFood
            return localFood
        }
        
        // Then try remote
        let remoteFood = try await remote.loadFood(by: id)
        cacheById[id] = remoteFood
        return remoteFood
    }
}

