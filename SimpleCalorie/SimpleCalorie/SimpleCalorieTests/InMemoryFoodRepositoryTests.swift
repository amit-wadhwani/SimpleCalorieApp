import XCTest
@testable import SimpleCalorie

@MainActor
final class InMemoryFoodRepositoryTests: XCTestCase {
    func testAddAndLoadMealsIsolatedByDate() {
        let repo = InMemoryFoodRepository()
        let today = Date(timeIntervalSince1970: 0)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let oatmeal = FoodItem(name: "Oatmeal", calories: 150, description: "100g")
        let yogurt = FoodItem(name: "Yogurt", calories: 90, description: "cup")

        _ = repo.add(oatmeal, to: .breakfast, on: today)
        _ = repo.add(yogurt, to: .breakfast, on: tomorrow)

        let todayMeals = repo.loadMeals(on: today)
        let tomorrowMeals = repo.loadMeals(on: tomorrow)

        XCTAssertEqual(todayMeals.breakfast, [oatmeal])
        XCTAssertEqual(tomorrowMeals.breakfast, [yogurt])
    }

    func testRemoveDeletesOnlyMatchingItem() {
        let repo = InMemoryFoodRepository()
        let date = Date(timeIntervalSince1970: 0)
        let toast = FoodItem(name: "Toast", calories: 120, description: "2 slices")
        let eggs = FoodItem(name: "Eggs", calories: 140, description: "2 scrambled")

        _ = repo.add(toast, to: .breakfast, on: date)
        _ = repo.add(eggs, to: .breakfast, on: date)

        _ = repo.remove(toast, from: .breakfast, on: date)

        let meals = repo.loadMeals(on: date)
        XCTAssertEqual(meals.breakfast, [eggs])
    }
}
