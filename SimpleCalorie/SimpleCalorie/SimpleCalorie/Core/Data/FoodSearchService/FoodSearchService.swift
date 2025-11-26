import Foundation

protocol FoodSearchService {
    /// Search by free-text query, e.g. "oats", "chicken", "rice".
    func searchFoods(matching query: String) async throws -> [FoodDefinition]

    /// Lookup by barcode (optional for Phase 1; can return nil).
    func lookupFood(byBarcode barcode: String) async throws -> FoodDefinition?
}

