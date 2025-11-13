import Foundation
import SwiftUI

final class TodayViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var meals: [MealType: [FoodItem]] = [
        .breakfast: [
            FoodItem(name: "Oatmeal with berries", calories: 245, description: "Oatmeal with berries"),
            FoodItem(name: "Black coffee", calories: 0, description: "Black coffee")
        ],
        .lunch: [
            FoodItem(name: "Grilled chicken salad", calories: 430, description: "Grilled chicken salad\nApple")
        ],
        .dinner: [
            FoodItem(name: "Greek yogurt", calories: 150, description: "Greek yogurt")
        ],
        .snacks: []
    ]
    
    // Basic demo values
    @Published var dailyGoalCalories: Double = 1800
    @Published var consumedCalories: Double = 0
    
    init() {
        consumedCalories = calculateConsumedCalories()
    }
    
    func add(_ item: FoodItem, to meal: MealType) {
        meals[meal, default: []].append(item)
        consumedCalories = calculateConsumedCalories()
    }
    
    private func calculateConsumedCalories() -> Double {
        meals.values.flatMap { $0 }.reduce(0) { $0 + Double($1.calories) }
    }
    
    func totalCalories(for meal: MealType) -> Int {
        Int(meals[meal]?.reduce(0) { $0 + $1.calories } ?? 0)
    }
}

