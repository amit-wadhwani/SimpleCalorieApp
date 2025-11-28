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
        let repo = TestFoodRepository(foods: foods)
        let viewModel = AddFoodViewModel(foodRepository: repo)

        // Initially query is empty, so no results
        await viewModel.refresh()
        XCTAssertEqual(viewModel.rows.count, 0, "Empty query should return no results")
        
        // Set a query that matches all foods
        viewModel.query = "chicken"
        await viewModel.refresh()
        
        XCTAssertEqual(viewModel.rows.count, 1, "Query 'chicken' should match Chicken Breast")
        XCTAssertEqual(viewModel.rows.first?.protein, "31g")
        XCTAssertEqual(viewModel.rows.first?.fat, "3.6g")
        
        // Test with query that matches both
        viewModel.query = "e"
        await viewModel.refresh()
        XCTAssertEqual(viewModel.rows.count, 2, "Query 'e' should match both foods")
        XCTAssertEqual(viewModel.rows.last?.kcal, "389")
        
        // Verify search was called
        XCTAssertGreaterThanOrEqual(repo.searchCalls.count, 1, "Search should be called")
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
        let repo = TestFoodRepository(foods: foods)
        let viewModel = AddFoodViewModel(foodRepository: repo)

        viewModel.query = "salM"
        await viewModel.refresh()

        XCTAssertEqual(viewModel.rows.count, 1)
        XCTAssertEqual(viewModel.rows.first?.name, "Salmon")
        
        // Verify search was called with correct query
        XCTAssertGreaterThanOrEqual(repo.searchCalls.count, 1, "Search should be called")
        if let lastCall = repo.searchCalls.last {
            XCTAssertEqual(lastCall, "salM", "Search should be called with query")
        }
    }
}
