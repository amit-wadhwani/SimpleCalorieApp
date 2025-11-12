import Foundation

@MainActor
final class AddFoodViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var rows: [FoodRowProps] = []
    private let service: FoodSearchService

    init(service: FoodSearchService) {
        self.service = service
        Task { await refresh() }
    }

    func refresh() async {
        let foods = await service.search(query: query)
        rows = foods.map { food in
            FoodRowProps(
                id: food.id,
                name: food.name,
                serving: "\(food.servingGrams)g",
                protein: "\(trim(food.macros.protein))g",
                carbs: "\(trim(food.macros.carbs))g",
                fat: "\(trim(food.macros.fat))g",
                kcal: "\(food.kcal)"
            )
        }
    }

    private func trim(_ v: Double) -> String {
        if v.rounded() == v { return String(Int(v)) }
        return String(format: "%.1f", v)
    }
}

