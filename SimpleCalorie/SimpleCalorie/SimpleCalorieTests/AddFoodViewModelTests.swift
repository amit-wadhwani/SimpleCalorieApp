import XCTest
@testable import SimpleCalorie

@MainActor
final class AddFoodViewModelTests: XCTestCase {
    func testRefreshBuildsFoodRowsWithFormatting() async {
        let foods = [
            Food(id: UUID(), name: "Chicken Breast", servingGrams: 100, macros: .init(protein: 31, carbs: 0, fat: 3.6), kcal: 165),
            Food(id: UUID(), name: "Oatmeal", servingGrams: 100, macros: .init(protein: 17, carbs: 68, fat: 7.2), kcal: 389)
        ]
        let viewModel = AddFoodViewModel(service: StubFoodSearchService(foods: foods))

        await viewModel.refresh()

        XCTAssertEqual(viewModel.rows.count, 2)
        XCTAssertEqual(viewModel.rows.first?.protein, "31g")
        XCTAssertEqual(viewModel.rows.first?.fat, "3.6g")
        XCTAssertEqual(viewModel.rows.last?.kcal, "389")
    }

    func testQueryFiltersResultsCaseInsensitively() async {
        let foods = [
            Food(id: UUID(), name: "Salmon", servingGrams: 100, macros: .init(protein: 20, carbs: 0, fat: 13), kcal: 208),
            Food(id: UUID(), name: "Avocado", servingGrams: 100, macros: .init(protein: 2, carbs: 9, fat: 15), kcal: 160)
        ]
        let viewModel = AddFoodViewModel(service: StubFoodSearchService(foods: foods))

        viewModel.query = "salM"
        await viewModel.refresh()

        XCTAssertEqual(viewModel.rows.count, 1)
        XCTAssertEqual(viewModel.rows.first?.name, "Salmon")
    }
}

private struct StubFoodSearchService: FoodSearchService {
    let foods: [Food]

    func search(query: String) async -> [Food] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return foods }
        return foods.filter { $0.name.lowercased().contains(trimmed.lowercased()) }
    }
}
