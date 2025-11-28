import Foundation

struct FoodDefinition: Identifiable, Codable, Equatable {
    enum SourceKind: String, Codable {
        case localDemo
        case usda
        case openFoodFacts
        case nutritionix
    }

    struct Macros: Codable, Equatable {
        let calories: Int
        let protein: Double
        let carbs: Double
        let fat: Double
    }

    struct Micronutrients: Codable, Equatable {
        let fiber: Double       // grams
        let sugar: Double       // grams (total sugars)
        let sodium: Double      // milligrams
        let cholesterol: Double // milligrams
        let potassium: Double   // milligrams
    }

    struct Serving: Codable, Equatable {
        let unit: String      // e.g., "g", "ml", "cup"
        let amount: Double    // e.g., 100.0
        let description: String? // e.g., "100g", "1 cup cooked"
    }

    struct ServingOption: Codable, Equatable, Identifiable {
        let id: UUID
        let label: String        // display string, e.g. "100g", "1 cup"
        let amountInGrams: Double
    }

    struct SourceMetadata: Codable, Equatable {
        let kind: SourceKind
        let providerId: String?     // e.g., USDA FDC ID, OFF barcode, etc.
        let lastUpdatedAt: Date?
    }

    let id: UUID
    let name: String              // e.g., "Chicken breast, cooked"
    let brand: String?            // nil for generic foods
    let serving: Serving          // default serving
    let servingOptions: [ServingOption]? // optional alternatives, e.g. [100g, 1 cup, 2 cups]
    let macros: Macros
    let micronutrients: Micronutrients?
    let source: SourceMetadata
    
    init(
        id: UUID,
        name: String,
        brand: String?,
        serving: Serving,
        servingOptions: [ServingOption]?,
        macros: Macros,
        micronutrients: Micronutrients? = nil,
        source: SourceMetadata
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.serving = serving
        self.servingOptions = servingOptions
        self.macros = macros
        self.micronutrients = micronutrients
        self.source = source
    }
}

// MARK: - FDC Nutrient Mapping Extension

extension FoodDefinition.Macros {
    /// Initialize Macros from FDC nutrients
    /// - Parameter nutrients: Array of FDCFoodNutrient from FDC API
    init(from nutrients: [FDCFoodNutrient]) {
        // Helper to find nutrient value by matching names
        func nutrientValue(matching names: [String], unit: String? = "g") -> Double? {
            for nutrient in nutrients {
                guard let amount = nutrient.amount, amount > 0 else { continue }
                guard let nutrientInfo = nutrient.nutrient else { continue }
                
                let nutrientName = nutrientInfo.name.lowercased()
                let unitName = nutrientInfo.unitName?.lowercased() ?? ""
                
                // Check if name matches any of the search terms
                let nameMatches = names.contains { searchTerm in
                    nutrientName.contains(searchTerm.lowercased())
                }
                
                if !nameMatches {
                    continue
                }
                
                // Check unit if specified
                if let requiredUnit = unit {
                    // For energy, be more flexible with units
                    if names.contains(where: { $0.lowercased() == "energy" }) {
                        // Accept kcal, cal, or empty for energy
                        if unitName == requiredUnit.lowercased() || unitName == "cal" || unitName.isEmpty {
                            return amount
                        }
                    } else {
                        // For other nutrients, require exact unit match or empty
                        if unitName == requiredUnit.lowercased() || unitName.isEmpty {
                            return amount
                        }
                    }
                } else {
                    return amount
                }
            }
            return nil
        }
        
        // Energy (calories) - prefer kcal, but handle kJ conversion
        var caloriesValue: Int = 0
        for nutrient in nutrients {
            guard let amount = nutrient.amount, amount > 0 else { continue }
            guard let nutrientInfo = nutrient.nutrient else { continue }
            
            let nutrientName = nutrientInfo.name.lowercased()
            let unitName = nutrientInfo.unitName?.lowercased() ?? ""
            
            if nutrientName.contains("energy") {
                if unitName == "kj" {
                    // Convert kJ → kcal (1 kJ ≈ 0.239006 kcal)
                    caloriesValue = Int((amount * 0.239006).rounded())
                } else if unitName == "kcal" || unitName == "cal" || unitName.isEmpty {
                    caloriesValue = Int(amount.rounded())
                }
                break
            }
        }
        
        // Protein
        let proteinValue = nutrientValue(matching: ["protein"], unit: "g") ?? 0
        
        // Carbohydrates (prefer "Carbohydrate, by difference")
        let carbsValue = nutrientValue(matching: ["carbohydrate, by difference", "carbohydrate"], unit: "g") ?? 0
        
        // Fat (prefer "Total lipid (fat)")
        let fatValue = nutrientValue(matching: ["total lipid (fat)", "total lipid", "fat"], unit: "g") ?? 0
        
        self.calories = caloriesValue
        self.protein = proteinValue
        self.carbs = carbsValue
        self.fat = fatValue
    }
}
