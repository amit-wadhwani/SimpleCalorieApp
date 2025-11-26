import Foundation

struct MockFoodSearchService: FoodSearchService {
    private let all: [FoodDefinition] = [
        FoodDefinition(
            id: UUID(),
            name: "Chicken Breast",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 165, protein: 31, carbs: 0, fat: 3.6),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        ),
        FoodDefinition(
            id: UUID(),
            name: "Brown Rice",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 112, protein: 2.8, carbs: 24, fat: 0.9),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        ),
        FoodDefinition(
            id: UUID(),
            name: "Salmon",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 208, protein: 20, carbs: 0, fat: 13),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        ),
        FoodDefinition(
            id: UUID(),
            name: "Avocado",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 160, protein: 2, carbs: 9, fat: 15),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        ),
        FoodDefinition(
            id: UUID(),
            name: "Oatmeal",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 389, protein: 17, carbs: 68, fat: 7),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        ),
        FoodDefinition(
            id: UUID(),
            name: "Greek Yogurt",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 59, protein: 10, carbs: 2.6, fat: 0.4),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
    ]

    func searchFoods(matching query: String) async throws -> [FoodDefinition] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.name.lowercased().contains(q) }
    }

    func lookupFood(byBarcode barcode: String) async throws -> FoodDefinition? {
        return nil
    }
}

