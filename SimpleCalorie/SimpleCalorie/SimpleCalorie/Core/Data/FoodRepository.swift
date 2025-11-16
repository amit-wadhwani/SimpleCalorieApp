import Foundation

struct Meals: Equatable {
    var breakfast: [FoodItem]
    var lunch: [FoodItem]
    var dinner: [FoodItem]
    var snacks: [FoodItem]
    
    func items(for meal: MealType) -> [FoodItem] {
        switch meal {
        case .breakfast: return breakfast
        case .lunch: return lunch
        case .dinner: return dinner
        case .snacks: return snacks
        }
    }
    
    var allItems: [FoodItem] {
        breakfast + lunch + dinner + snacks
    }
}

protocol FoodRepository {
    @discardableResult
    func loadMeals(on date: Date) -> Meals

    @discardableResult
    func add(_ item: FoodItem, to meal: MealType, on date: Date) -> Bool

    @discardableResult
    func remove(_ item: FoodItem, from meal: MealType, on date: Date) -> Bool
}

