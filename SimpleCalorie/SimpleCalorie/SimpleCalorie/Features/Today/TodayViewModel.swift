import Foundation
import SwiftUI
import UIKit

@MainActor
final class TodayViewModel: ObservableObject {
    private let repo: FoodRepository
    private let dateKey = "today.selectedDate"

    @Published var date: Date
    @Published var meals: Meals
    @Published var isDatePickerPresented: Bool = false
    @AppStorage("showAds") var showAds: Bool = true
    
    // Basic demo values
    @Published var dailyGoalCalories: Double = 1800
    @Published var consumedCalories: Double = 0
    @Published var protein: Double = 0
    @Published var carbs: Double = 0
    @Published var fat: Double = 0
    @Published var isMacrosCollapsed: Bool = false
    
    // Macro goals
    var proteinGoal: Double = 135
    var carbsGoal: Double = 225
    var fatGoal: Double = 60
    
    // Computed property for backward compatibility
    var selectedDate: Date {
        get { date }
        set { date = newValue }
    }
    
    init(repo: FoodRepository = InMemoryFoodRepository(), date: Date = Date()) {
        self.repo = repo
        self.date = date
        
        // Load initial demo data if empty
        let loaded = repo.loadMeals(on: date)
        if loaded.breakfast.isEmpty && loaded.lunch.isEmpty && loaded.dinner.isEmpty && loaded.snacks.isEmpty {
            // Seed with demo data
            let demoMeals = Meals(
                breakfast: [
                    FoodItem(name: "Oatmeal with berries", calories: 245, description: "100g", protein: 8.0, carbs: 45.0, fat: 5.0),
                    FoodItem(name: "Black coffee", calories: 0, description: "1 cup", protein: 0, carbs: 0, fat: 0)
                ],
                lunch: [
                    FoodItem(name: "Grilled chicken salad", calories: 430, description: "200g", protein: 50.0, carbs: 15.0, fat: 12.0)
                ],
                dinner: [
                    FoodItem(name: "Greek yogurt", calories: 150, description: "200g", protein: 20.0, carbs: 8.0, fat: 2.0)
                ],
                snacks: []
            )
            // Save demo data
            for mealType in MealType.allCases {
                for item in demoMeals.items(for: mealType) {
                    _ = repo.add(item, to: mealType, on: date)
                }
            }
            self.meals = repo.loadMeals(on: date)
        } else {
            self.meals = loaded
        }
        
        restoreDateIfAvailable()
        recalcTotals()
    }
    
    func add(_ item: FoodItem, to meal: MealType) {
        _ = repo.add(item, to: meal, on: date)
        meals = repo.loadMeals(on: date)
        recalcTotals()
    }
    
    func remove(_ item: FoodItem, from meal: MealType) {
        _ = repo.remove(item, from: meal, on: date)
        meals = repo.loadMeals(on: date)
        recalcTotals()
    }
    
    func didChangeDate() {
        meals = repo.loadMeals(on: date)
        recalcTotals()
        persistDate()
    }
    
    func persistDate() {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: dateKey)
    }
    
    func restoreDateIfAvailable() {
        if let t = UserDefaults.standard.object(forKey: dateKey) as? TimeInterval {
            self.date = Date(timeIntervalSince1970: t)
            meals = repo.loadMeals(on: date)
            recalcTotals()
        }
    }
    
    private func recalcTotals() {
        consumedCalories = calculateConsumedCalories()
        protein = calculateProtein()
        carbs = calculateCarbs()
        fat = calculateFat()
    }
    
    private func calculateConsumedCalories() -> Double {
        meals.allItems.reduce(0) { $0 + Double($1.calories) }
    }
    
    private func calculateProtein() -> Double {
        meals.allItems.reduce(0) { $0 + $1.protein }
    }
    
    private func calculateCarbs() -> Double {
        meals.allItems.reduce(0) { $0 + $1.carbs }
    }
    
    private func calculateFat() -> Double {
        meals.allItems.reduce(0) { $0 + $1.fat }
    }
    
    func totalCalories(for meal: MealType) -> Int {
        Int(meals.items(for: meal).reduce(0) { $0 + $1.calories })
    }
    
    func goToPreviousDay() {
        date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        didChangeDate()
    }
    
    func goToNextDay() {
        date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        didChangeDate()
    }
    
    // For date picker changes
    func setDate(_ newDate: Date) {
        date = newDate
        didChangeDate()
    }
}

