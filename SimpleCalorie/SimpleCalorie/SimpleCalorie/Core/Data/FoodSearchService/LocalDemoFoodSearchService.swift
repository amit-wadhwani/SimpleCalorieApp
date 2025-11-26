import Foundation

final class LocalDemoFoodSearchService: FoodSearchService {
    private let foods: [FoodDefinition]

    init(bundle: Bundle = .main) {
        // Load demo JSON from bundle; on failure, fall back to an empty array.
        if let url = bundle.url(forResource: "food_demo", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([FoodDefinition].self, from: data) {
            self.foods = decoded
        } else {
            self.foods = []
        }
    }

    func searchFoods(matching query: String) async throws -> [FoodDefinition] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // naive case-insensitive substring search over name + brand
        let lower = trimmed.lowercased()
        return foods.filter { food in
            let nameMatch  = food.name.lowercased().contains(lower)
            let brandMatch = food.brand?.lowercased().contains(lower) ?? false
            return nameMatch || brandMatch
        }
    }

    func lookupFood(byBarcode barcode: String) async throws -> FoodDefinition? {
        // Phase 1: optional demo entries with barcodes in providerId.
        foods.first { $0.source.providerId == barcode }
    }
}


