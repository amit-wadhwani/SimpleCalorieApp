import Foundation

@MainActor
final class InMemoryFoodRepository: FoodRepository {
    private var store: [String: Meals] = [:]
    
    nonisolated init() {
        // Initializer is nonisolated; all methods are @MainActor isolated
    }

    private func key(for date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    @discardableResult
    func loadMeals(on date: Date) -> Meals {
        store[key(for: date)] ?? Meals(breakfast: [], lunch: [], dinner: [], snacks: [])
    }

    @discardableResult
    func add(_ item: FoodItem, to meal: MealType, on date: Date) -> Bool {
        let k = key(for: date)
        var m = loadMeals(on: date)
        switch meal {
        case .breakfast: m.breakfast.append(item)
        case .lunch:     m.lunch.append(item)
        case .dinner:    m.dinner.append(item)
        case .snacks:    m.snacks.append(item)
        }
        store[k] = m
        return true
    }

    @discardableResult
    func remove(_ item: FoodItem, from meal: MealType, on date: Date) -> Bool {
        let k = key(for: date)
        var m = loadMeals(on: date)
        func removeFirst(_ arr: inout [FoodItem]) {
            if let i = arr.firstIndex(where: { $0.id == item.id }) { arr.remove(at: i) }
        }
        switch meal {
        case .breakfast: removeFirst(&m.breakfast)
        case .lunch:     removeFirst(&m.lunch)
        case .dinner:    removeFirst(&m.dinner)
        case .snacks:    removeFirst(&m.snacks)
        }
        store[k] = m
        return true
    }
}

