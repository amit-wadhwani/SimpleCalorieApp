import Foundation
@testable import SimpleCalorie

/// Test implementation of FoodDefinitionRepository for use in unit tests
final class TestFoodRepository: FoodDefinitionRepository {
    /// Mutable array of foods for test setup
    var foods: [FoodDefinition] = []
    
    /// Track search calls for assertions
    var searchCalls: [String] = []
    
    /// Track loaded IDs for assertions
    var loadedIds: [UUID] = []
    
    init(foods: [FoodDefinition] = []) {
        self.foods = foods
    }
    
    func searchFoods(query: String, limit: Int) async throws -> [FoodDefinition] {
        searchCalls.append(query)
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        let lower = trimmed.lowercased()
        let results = foods.filter { food in
            food.name.lowercased().contains(lower) ||
            (food.brand?.lowercased().contains(lower) ?? false)
        }
        
        return Array(results.prefix(limit))
    }
    
    func loadFood(by id: UUID) async throws -> FoodDefinition {
        loadedIds.append(id)
        if let food = foods.first(where: { $0.id == id }) {
            return food
        }
        throw FoodDefinitionRepositoryError.notFound
    }
}

