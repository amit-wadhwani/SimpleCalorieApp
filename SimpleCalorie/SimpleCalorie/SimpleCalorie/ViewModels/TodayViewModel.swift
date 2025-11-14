import Foundation
import SwiftUI
import UIKit

final class TodayViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var isDatePickerPresented: Bool = false
    @Published var meals: [MealType: [FoodItem]] = [
        .breakfast: [
            FoodItem(name: "Oatmeal with berries", calories: 245, description: "100g", protein: 8.0, carbs: 45.0, fat: 5.0),
            FoodItem(name: "Black coffee", calories: 0, description: "1 cup", protein: 0, carbs: 0, fat: 0)
        ],
        .lunch: [
            FoodItem(name: "Grilled chicken salad", calories: 430, description: "200g", protein: 50.0, carbs: 15.0, fat: 12.0)
        ],
        .dinner: [
            FoodItem(name: "Greek yogurt", calories: 150, description: "200g", protein: 20.0, carbs: 8.0, fat: 2.0)
        ],
        .snacks: []
    ]
    
    // Basic demo values
    @Published var dailyGoalCalories: Double = 1800
    @Published var consumedCalories: Double = 0
    @Published var protein: Double = 0
    @Published var carbs: Double = 0
    @Published var fat: Double = 0
    
    // Macro goals
    var proteinGoal: Double = 135
    var carbsGoal: Double = 225
    var fatGoal: Double = 60
    
    init() {
        recalcTotals()
    }
    
    func add(_ item: FoodItem, to meal: MealType) {
        meals[meal, default: []].append(item)
        recalcTotals()
        haptic(.success)
    }
    
    func remove(_ item: FoodItem, from meal: MealType) {
        meals[meal]?.removeAll { $0.id == item.id }
        recalcTotals()
    }
    
    private func recalcTotals() {
        consumedCalories = calculateConsumedCalories()
        protein = calculateProtein()
        carbs = calculateCarbs()
        fat = calculateFat()
    }
    
    private func calculateConsumedCalories() -> Double {
        meals.values.flatMap { $0 }.reduce(0) { $0 + Double($1.calories) }
    }
    
    private func calculateProtein() -> Double {
        meals.values.flatMap { $0 }.reduce(0) { $0 + $1.protein }
    }
    
    private func calculateCarbs() -> Double {
        meals.values.flatMap { $0 }.reduce(0) { $0 + $1.carbs }
    }
    
    private func calculateFat() -> Double {
        meals.values.flatMap { $0 }.reduce(0) { $0 + $1.fat }
    }
    
    func totalCalories(for meal: MealType) -> Int {
        Int(meals[meal]?.reduce(0) { $0 + $1.calories } ?? 0)
    }
    
    func goToPreviousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    func goToNextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
    
    private func haptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

