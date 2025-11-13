import Foundation

struct FoodItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let calories: Int
    let description: String   // e.g. "Oatmeal with berries" or "100g"
    
    // Optional macro info for future use
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

