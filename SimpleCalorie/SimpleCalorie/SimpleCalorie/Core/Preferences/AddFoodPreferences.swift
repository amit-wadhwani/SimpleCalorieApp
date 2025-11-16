import SwiftUI

enum AddFoodPreferences {
    @AppStorage("addFood.lastSelectedMeal") private static var lastRaw: String = MealType.breakfast.rawValue

    static var lastSelected: MealType {
        MealType(rawValue: lastRaw) ?? .breakfast
    }

    static func set(_ meal: MealType) {
        if lastRaw != meal.rawValue {
            lastRaw = meal.rawValue
        }
    }
}

