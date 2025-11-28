import Foundation

/// Local in-memory food repository that loads from demo JSON or seed data
final class LocalFoodRepository: FoodDefinitionRepository {
    private var foodsById: [UUID: FoodDefinition]
    
    /// Initialize with seed foods (for testing or explicit seeding)
    init(seedFoods: [FoodDefinition]) {
        self.foodsById = Dictionary(uniqueKeysWithValues: seedFoods.map { ($0.id, $0) })
    }
    
    /// Initialize by loading from bundle JSON (default production behavior)
    init(bundle: Bundle = .main) {
        // Load demo JSON from bundle; on failure, fall back to an empty array.
        let loadedFoods: [FoodDefinition]
        if let url = bundle.url(forResource: "food_demo", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([FoodDefinition].self, from: data) {
            loadedFoods = decoded
        } else {
            loadedFoods = []
        }
        self.foodsById = Dictionary(uniqueKeysWithValues: loadedFoods.map { ($0.id, $0) })
    }
    
    func searchFoods(query: String, limit: Int = 100) async throws -> [FoodDefinition] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        let lower = trimmed.lowercased()
        let results = foodsById.values.filter { food in
            food.name.lowercased().contains(lower) ||
            (food.brand?.lowercased().contains(lower) ?? false)
        }
        
        return Array(results.prefix(limit))
    }
    
    func loadFood(by id: UUID) async throws -> FoodDefinition {
        if let food = foodsById[id] {
            return food
        }
        throw FoodDefinitionRepositoryError.notFound
    }
}

