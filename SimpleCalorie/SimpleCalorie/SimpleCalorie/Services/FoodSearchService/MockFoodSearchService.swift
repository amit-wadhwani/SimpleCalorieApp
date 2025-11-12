import Foundation

struct MockFoodSearchService: FoodSearchService {
    private let all: [Food] = [
        Food(id: UUID(), name: "Chicken Breast", servingGrams: 100,
             macros: .init(protein: 31, carbs: 0, fat: 3.6), kcal: 165),
        Food(id: UUID(), name: "Brown Rice", servingGrams: 100,
             macros: .init(protein: 2.6, carbs: 24, fat: 0.9), kcal: 112)
    ]

    func search(query: String) async -> [Food] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.name.lowercased().contains(q) }
    }
}

