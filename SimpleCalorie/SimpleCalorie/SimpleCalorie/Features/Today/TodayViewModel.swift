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
    @Published var isCopyFromDateSheetPresented: Bool = false
    @Published var copyFromDateSelectedDate: Date = Date()
    @Published var copyFromDateDestinationMealKind: MealSuggestionTargetMealKind? = nil
    @Published var copyFromDateSourceMealKind: MealSuggestionTargetMealKind? = nil
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
    
    init(repo: FoodRepository = InMemoryFoodRepository(), date: Date = Date(), seedDemoData: Bool = true) {
        self.repo = repo
        self.date = date
        
        // Load initial demo data if empty
        let loaded = repo.loadMeals(on: date)
        if seedDemoData && loaded.breakfast.isEmpty && loaded.lunch.isEmpty && loaded.dinner.isEmpty && loaded.snacks.isEmpty {
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

// MARK: - Quick Add Meal Suggestions
extension TodayViewModel {
    enum MealSuggestionTargetMealKind: String, CaseIterable {
        case breakfast, lunch, dinner, snacks
        
        var displayName: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            case .snacks: return "Snacks"
            }
        }
    }
    
    enum MealSuggestion {
        case yesterdayBreakfast
        case lastWeekBreakfast
        case yesterdayLunch
        case lastNightDinner
        case yesterdayDinner
        case lastWeekDinner
        case yesterdaySnacks
        case lastWeekSnacks
        case copyFromDateBreakfast
        case copyFromDateLunch
        case copyFromDateDinner
        case copyFromDateSnacks
    }
    
    func handleMealSuggestion(_ suggestion: MealSuggestion) {
        let targetDate = date
        let items: [FoodItem]
        let targetMeal: MealType
        
        switch suggestion {
        case .yesterdayBreakfast:
            items = sourceItemsForYesterday(mealKind: .breakfast)
            targetMeal = .breakfast
        case .lastWeekBreakfast:
            items = sourceItemsForLastWeek(mealKind: .breakfast)
            targetMeal = .breakfast
        case .yesterdayLunch:
            items = sourceItemsForYesterday(mealKind: .lunch)
            targetMeal = .lunch
        case .lastNightDinner:
            items = sourceItemsForLastNightDinner()
            targetMeal = .lunch
        case .yesterdayDinner:
            items = sourceItemsForYesterday(mealKind: .dinner)
            targetMeal = .dinner
        case .lastWeekDinner:
            items = sourceItemsForLastWeek(mealKind: .dinner)
            targetMeal = .dinner
        case .yesterdaySnacks:
            items = sourceItemsForYesterday(mealKind: .snacks)
            targetMeal = .snacks
        case .lastWeekSnacks:
            items = sourceItemsForLastWeek(mealKind: .snacks)
            targetMeal = .snacks
        case .copyFromDateBreakfast,
             .copyFromDateLunch,
             .copyFromDateDinner,
             .copyFromDateSnacks:
            // For this task you can still defer actual date picker logic;
            // just leave TODO and return for now. The UI will still call presentCopyFromDatePicker(for:).
            return
        }
        
        // Only copy if there are items to copy
        if !items.isEmpty {
            withAnimation(.easeInOut(duration: 0.25)) {
                addItems(items, to: targetMeal, on: targetDate)
            }
        }
    }
    
    func presentCopyFromDatePicker(for mealKind: SmartSuggestionsRow.MealKind) {
        // Map SmartSuggestionsRow.MealKind -> internal meal kind
        let destinationKind: MealSuggestionTargetMealKind
        switch mealKind {
        case .breakfast: destinationKind = .breakfast
        case .lunch:     destinationKind = .lunch
        case .dinner:    destinationKind = .dinner
        case .snacks:    destinationKind = .snacks
        }
        
        // Destination is the meal the user initiated from (where items will be copied to)
        copyFromDateDestinationMealKind = destinationKind
        
        // Use the same date as the Today screen's selectedDate (not Date() or yesterday)
        let calendar = Calendar.current
        let chosenDate = calendar.startOfDay(for: selectedDate)
        
        // For initial source meal kind, prefer the same meal kind as destination
        // but check if it has items on the selected date; otherwise use first available
        var initialSourceKind = destinationKind
        if hasItems(on: chosenDate, mealKind: destinationKind) {
            initialSourceKind = destinationKind
        } else if let firstAvailable = firstMealKindWithItems(on: chosenDate) {
            initialSourceKind = firstAvailable
        }
        
        // Update copy-from-date state
        self.copyFromDateSelectedDate = chosenDate
        self.copyFromDateSourceMealKind = initialSourceKind
        
        // Always present the sheet; let the sheet decide whether Copy is enabled.
        self.isCopyFromDateSheetPresented = true
    }
    
    func firstMealKindWithItems(on date: Date) -> MealSuggestionTargetMealKind? {
        for kind in MealSuggestionTargetMealKind.allCases {
            if hasItems(on: date, mealKind: kind) {
                return kind
            }
        }
        return nil
    }
    
    var previewItemsForCopyFromDate: [FoodItem] {
        guard let sourceMealKind = copyFromDateSourceMealKind else { return [] }
        return sourceItems(for: sourceMealKind, on: copyFromDateSelectedDate)
    }
    
    var previewTotalCaloriesForCopyFromDate: Int {
        previewItemsForCopyFromDate.reduce(0) { $0 + $1.calories }
    }
    
    var canConfirmCopyFromDate: Bool {
        !previewItemsForCopyFromDate.isEmpty
    }
    
    func hasItems(on date: Date, mealKind: MealSuggestionTargetMealKind) -> Bool {
        !sourceItems(for: mealKind, on: date).isEmpty
    }
    
    func confirmCopyFromDate() {
        guard let dest = copyFromDateDestinationMealKind,
              let src = copyFromDateSourceMealKind else { return }
        
        let sourceDate = copyFromDateSelectedDate
        let items = sourceItems(for: src, on: sourceDate)
        
        let destinationMeal: MealType
        switch dest {
        case .breakfast: destinationMeal = .breakfast
        case .lunch: destinationMeal = .lunch
        case .dinner: destinationMeal = .dinner
        case .snacks: destinationMeal = .snacks
        }
        
        if !items.isEmpty {
            withAnimation(.easeInOut(duration: 0.25)) {
                addItems(items, to: destinationMeal, on: date)
            }
        }
        
        isCopyFromDateSheetPresented = false
        copyFromDateDestinationMealKind = nil
        copyFromDateSourceMealKind = nil
    }
    
    private func sourceItems(for mealKind: MealSuggestionTargetMealKind, on date: Date) -> [FoodItem] {
        let meals = repo.loadMeals(on: date)
        switch mealKind {
        case .breakfast: return meals.breakfast
        case .lunch: return meals.lunch
        case .dinner: return meals.dinner
        case .snacks: return meals.snacks
        }
    }
    
    private func sourceItems(for mealKind: MealKind, on date: Date) -> [FoodItem] {
        let meals = repo.loadMeals(on: date)
        switch mealKind {
        case .breakfast: return meals.breakfast
        case .lunch: return meals.lunch
        case .dinner: return meals.dinner
        case .snacks: return meals.snacks
        }
    }
    
    // MARK: - Quick Add Source Meal Lookup
    
    enum MealKind {
        case breakfast, lunch, dinner, snacks
    }
    
    func sourceItemsForYesterday(mealKind: MealKind) -> [FoodItem] {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) else {
            return []
        }
        let yesterdayMeals = repo.loadMeals(on: yesterday)
        switch mealKind {
        case .breakfast: return yesterdayMeals.breakfast
        case .lunch: return yesterdayMeals.lunch
        case .dinner: return yesterdayMeals.dinner
        case .snacks: return yesterdayMeals.snacks
        }
    }
    
    func sourceItemsForLastWeek(mealKind: MealKind) -> [FoodItem] {
        guard let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: date) else {
            return []
        }
        let lastWeekMeals = repo.loadMeals(on: lastWeek)
        switch mealKind {
        case .breakfast: return lastWeekMeals.breakfast
        case .lunch: return lastWeekMeals.lunch
        case .dinner: return lastWeekMeals.dinner
        case .snacks: return lastWeekMeals.snacks
        }
    }
    
    func sourceItemsForLastNightDinner() -> [FoodItem] {
        guard let lastNight = Calendar.current.date(byAdding: .day, value: -1, to: date) else {
            return []
        }
        let lastNightMeals = repo.loadMeals(on: lastNight)
        return lastNightMeals.dinner
    }
    
    private func addItems(_ items: [FoodItem], to meal: MealType, on targetDate: Date) {
        for item in items {
            _ = repo.add(item, to: meal, on: targetDate)
        }
        // Reload meals for current date if we're adding to current date
        if targetDate == date {
            meals = repo.loadMeals(on: date)
            recalcTotals()
        }
    }
    
    // MARK: - Quick Add Availability
    
    var hasYesterdayBreakfast: Bool { !sourceItemsForYesterday(mealKind: .breakfast).isEmpty }
    var hasLastWeekBreakfast: Bool { !sourceItemsForLastWeek(mealKind: .breakfast).isEmpty }
    var hasYesterdayLunch: Bool { !sourceItemsForYesterday(mealKind: .lunch).isEmpty }
    var hasLastNightDinnerForLunch: Bool { !sourceItemsForLastNightDinner().isEmpty }
    var hasYesterdayDinner: Bool { !sourceItemsForYesterday(mealKind: .dinner).isEmpty }
    var hasLastWeekDinner: Bool { !sourceItemsForLastWeek(mealKind: .dinner).isEmpty }
    var hasYesterdaySnacks: Bool { !sourceItemsForYesterday(mealKind: .snacks).isEmpty }
    var hasLastWeekSnacks: Bool { !sourceItemsForLastWeek(mealKind: .snacks).isEmpty }
    
    // Legacy property name for backward compatibility
    var hasLastNightDinner: Bool { hasLastNightDinnerForLunch }
    
    var hasTodayLunchForDinner: Bool {
        hasItems(on: date, mealKind: MealSuggestionTargetMealKind.lunch)
    }
    
    func handleTodayLunchToDinner() {
        let targetDate = date
        let lunchItems = sourceItems(for: MealSuggestionTargetMealKind.lunch, on: targetDate)
        guard !lunchItems.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            addItems(lunchItems, to: .dinner, on: targetDate)
        }
    }
}

