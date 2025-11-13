import Foundation

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"

    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snacks: return "Snacks"
        }
    }
}

struct FoodEntry: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    // Minimal placeholders; we'll add macros later if needed
}

struct MacroSummary {
    var protein: (current: Int, target: Int)
    var carbs:   (current: Int, target: Int)
    var fat:     (current: Int, target: Int)
}

struct CalorieSummary {
    var consumed: Int
    var target:   Int
}

