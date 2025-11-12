import Foundation

struct MockFoodSearchService: FoodSearchService {
    private let all: [Food] = [
        Food(id: UUID(), name: "Chicken Breast", servingGrams: 100,
             macros: .init(protein: 31, carbs: 0, fat: 3.6), kcal: 165),
        Food(id: UUID(), name: "Brown Rice", servingGrams: 100,
             macros: .init(protein: 2.8, carbs: 24, fat: 0.9), kcal: 112),
        Food(id: UUID(), name: "Salmon", servingGrams: 100,
             macros: .init(protein: 20, carbs: 0, fat: 13), kcal: 208),
        Food(id: UUID(), name: "Avocado", servingGrams: 100,
             macros: .init(protein: 2, carbs: 9, fat: 15), kcal: 160),
        Food(id: UUID(), name: "Oatmeal", servingGrams: 100,
             macros: .init(protein: 17, carbs: 68, fat: 7), kcal: 389),
        Food(id: UUID(), name: "Greek Yogurt", servingGrams: 100,
             macros: .init(protein: 10, carbs: 2.6, fat: 0.4), kcal: 59)
    ]

    func search(query: String) async -> [Food] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.name.lowercased().contains(q) }
    }
}

