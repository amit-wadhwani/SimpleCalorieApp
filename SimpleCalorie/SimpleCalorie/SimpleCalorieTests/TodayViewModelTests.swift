import XCTest
@testable import SimpleCalorie

@MainActor
final class TodayViewModelTests: XCTestCase {
    func testTotalsReflectMealsFromRepository() {
        let date = Date(timeIntervalSince1970: 0)
        let meals = Meals(
            breakfast: [FoodItem(name: "Oats", calories: 200, description: "1 cup", protein: 8, carbs: 34, fat: 4)],
            lunch: [FoodItem(name: "Chicken", calories: 320, description: "150g", protein: 45, carbs: 2, fat: 8)],
            dinner: [],
            snacks: []
        )
        let repo = StubFoodRepository(initialMeals: meals, date: date)

        UserDefaults.standard.removeObject(forKey: "today.selectedDate")
        let viewModel = TodayViewModel(repo: repo, date: date, seedDemoData: false)

        XCTAssertEqual(viewModel.totalCalories(for: .breakfast), 200)
        XCTAssertEqual(viewModel.totalCalories(for: .lunch), 320)
        XCTAssertEqual(viewModel.consumedCalories, 520)
        XCTAssertEqual(viewModel.protein, 53)
        XCTAssertEqual(viewModel.carbs, 36)
        XCTAssertEqual(viewModel.fat, 12)
    }

    func testAddingFoodUpdatesTotals() {
        let date = Date(timeIntervalSince1970: 0)
        let repo = StubFoodRepository(initialMeals: Meals(breakfast: [], lunch: [], dinner: [], snacks: []), date: date)
        UserDefaults.standard.removeObject(forKey: "today.selectedDate")
        let viewModel = TodayViewModel(repo: repo, date: date, seedDemoData: false)

        let toast = FoodItem(name: "Toast", calories: 120, description: "2 slices", protein: 4, carbs: 22, fat: 2)
        viewModel.add(toast, to: .breakfast)

        XCTAssertEqual(viewModel.meals.breakfast, [toast])
        XCTAssertEqual(viewModel.consumedCalories, 120)
        XCTAssertEqual(viewModel.carbs, 22)
    }
}

@MainActor
private final class StubFoodRepository: FoodRepository {
    private var store: [String: Meals]
    private let formatter: DateFormatter

    init(initialMeals: Meals, date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        self.formatter = formatter

        let key = formatter.string(from: date)
        self.store = [key: initialMeals]
    }

    private func key(for date: Date) -> String {
        formatter.string(from: date)
    }

    func loadMeals(on date: Date) -> Meals {
        store[key(for: date)] ?? Meals(breakfast: [], lunch: [], dinner: [], snacks: [])
    }

    @discardableResult
    func add(_ item: FoodItem, to meal: MealType, on date: Date) -> Bool {
        var meals = loadMeals(on: date)
        switch meal {
        case .breakfast: meals.breakfast.append(item)
        case .lunch: meals.lunch.append(item)
        case .dinner: meals.dinner.append(item)
        case .snacks: meals.snacks.append(item)
        }
        store[key(for: date)] = meals
        return true
    }

    @discardableResult
    func remove(_ item: FoodItem, from meal: MealType, on date: Date) -> Bool {
        var meals = loadMeals(on: date)
        func removeFirst(_ arr: inout [FoodItem]) { arr.removeAll { $0.id == item.id } }
        switch meal {
        case .breakfast: removeFirst(&meals.breakfast)
        case .lunch: removeFirst(&meals.lunch)
        case .dinner: removeFirst(&meals.dinner)
        case .snacks: removeFirst(&meals.snacks)
        }
        store[key(for: date)] = meals
        return true
    }
}
