import XCTest
@testable import SimpleCalorie

@MainActor
final class AddFoodViewModelTests: XCTestCase {
    func testRefreshBuildsFoodRowsWithFormatting() async {
        let foods = [
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
                name: "Oatmeal",
                brand: nil,
                serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
                servingOptions: nil,
                macros: FoodDefinition.Macros(calories: 389, protein: 17, carbs: 68, fat: 7.2),
                source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
            )
        ]
        let viewModel = AddFoodViewModel(searchService: StubFoodSearchService(foods: foods))

        await viewModel.refresh()

        XCTAssertEqual(viewModel.rows.count, 2)
        XCTAssertEqual(viewModel.rows.first?.protein, "31g")
        XCTAssertEqual(viewModel.rows.first?.fat, "3.6g")
        XCTAssertEqual(viewModel.rows.last?.kcal, "389")
    }

    func testQueryFiltersResultsCaseInsensitively() async {
        let foods = [
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
            )
        ]
        let viewModel = AddFoodViewModel(searchService: StubFoodSearchService(foods: foods))

        viewModel.query = "salM"
        await viewModel.refresh()

        XCTAssertEqual(viewModel.rows.count, 1)
        XCTAssertEqual(viewModel.rows.first?.name, "Salmon")
    }
}

private struct StubFoodSearchService: FoodSearchService {
    let foods: [FoodDefinition]

    func searchFoods(matching query: String) async throws -> [FoodDefinition] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return foods }
        return foods.filter { $0.name.lowercased().contains(trimmed.lowercased()) }
    }

    func lookupFood(byBarcode barcode: String) async throws -> FoodDefinition? {
        return nil
    }
}
