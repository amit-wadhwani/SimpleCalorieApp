import Foundation

struct MacroInfo: Codable, Equatable {
    let protein: Double
    let carbs: Double
    let fat: Double

    /// A simple calorie estimation based on standard macro multipliers.
    /// Uses 4 kcal per gram of protein and carbs, and 9 kcal per gram of fat.
    var caloriesEstimate: Int {
        Int(((protein * 4) + (carbs * 4) + (fat * 9)).rounded())
    }
}

