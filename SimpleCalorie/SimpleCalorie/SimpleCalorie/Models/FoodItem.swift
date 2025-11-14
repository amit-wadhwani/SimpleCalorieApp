import Foundation

struct FoodItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let calories: Int
    let description: String   // e.g. "100g" or "1 cup"
    
    // Macro info
    var protein: Double
    var carbs: Double
    var fat: Double
    
    init(name: String, calories: Int, description: String, protein: Double = 0, carbs: Double = 0, fat: Double = 0) {
        self.name = name
        self.calories = calories
        self.description = description
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}

