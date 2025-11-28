import Foundation

extension FoodDefinition {
    /// Map FDC food details to FoodDefinition
    /// - Parameters:
    ///   - details: FDCFoodDetailsResponse from FDC API
    ///   - preserveId: Optional UUID to preserve (for maintaining identity from search results)
    /// - Returns: FoodDefinition with mapped data
    static func fromFDC(details: FDCFoodDetailsResponse, preserveId: UUID? = nil) -> FoodDefinition {
        // Use provided UUID or generate new one, and store fdcId in providerId
        let id = preserveId ?? UUID()
        let fdcIdString = String(details.fdcId)
        
        // Map name and brand
        let name = details.description
        let brand = details.brandOwner
        
        // Determine base serving from foodPortions
        let (baseServing, servingOptions) = mapFDCServings(portions: details.foodPortions)
        
        // Map macros from foodNutrients using shared helper
        let macros = FoodDefinition.Macros(from: details.foodNutrients ?? [])
        
        // Map micronutrients from foodNutrients
        let micronutrients = FoodDefinition.Micronutrients(from: details.foodNutrients ?? [])
        
        // Create source metadata
        let source = SourceMetadata(
            kind: .usda,
            providerId: fdcIdString,
            lastUpdatedAt: Date()
        )
        
        return FoodDefinition(
            id: id,
            name: name,
            brand: brand,
            serving: baseServing,
            servingOptions: servingOptions.isEmpty ? nil : servingOptions,
            macros: macros,
            micronutrients: micronutrients,
            source: source
        )
    }
    
    // MARK: - Private Helpers
    
    private static func mapFDCServings(portions: [FDCFoodPortion]?) -> (Serving, [ServingOption]) {
        guard let portions = portions, !portions.isEmpty else {
            // Fallback to 100g serving if no portions
            return (
                Serving(unit: "g", amount: 100.0, description: "100g"),
                []
            )
        }
        
        // Find base serving: prefer portion with amount = 1 or 0.5 and useful modifier
        var basePortion: FDCFoodPortion?
        var baseIndex: Int?
        var bestScore: Double = 0
        
        for (index, portion) in portions.enumerated() {
            guard let gramWeight = portion.gramWeight, gramWeight > 0 else { continue }
            
            var score: Double = 0
            if let amount = portion.amount {
                // Prefer amount = 1.0, then 0.5, then other reasonable amounts
                if amount == 1.0 {
                    score = 10.0
                } else if amount == 0.5 {
                    score = 8.0
                } else if amount > 0 && amount <= 2.0 {
                    score = 5.0
                }
            }
            
            // Bonus for having a modifier
            if let modifier = portion.modifier, !modifier.isEmpty {
                score += 2.0
            }
            
            if score > bestScore {
                bestScore = score
                basePortion = portion
                baseIndex = index
            }
        }
        
        // If no match with scoring, use first portion with gramWeight
        if basePortion == nil {
            for (index, portion) in portions.enumerated() {
                if let gramWeight = portion.gramWeight, gramWeight > 0 {
                    basePortion = portion
                    baseIndex = index
                    break
                }
            }
        }
        
        // If still no match, use first portion or fallback
        let selectedPortion = basePortion ?? portions.first!
        let selectedIndex = baseIndex ?? 0
        
        // Build serving description
        let servingDescription = buildServingDescription(from: selectedPortion)
        
        // Create base serving
        let baseServing = Serving(
            unit: "g",
            amount: selectedPortion.gramWeight ?? 100.0,
            description: servingDescription
        )
        
        // Create serving options from other portions
        var servingOptions: [ServingOption] = []
        for (index, portion) in portions.enumerated() {
            if index == selectedIndex { continue }
            guard let gramWeight = portion.gramWeight, gramWeight > 0 else { continue }
            
            let label = buildServingDescription(from: portion)
            if !label.isEmpty {
                servingOptions.append(ServingOption(
                    id: UUID(),
                    label: label,
                    amountInGrams: gramWeight
                ))
            }
        }
        
        return (baseServing, servingOptions)
    }
    
    private static func buildServingDescription(from portion: FDCFoodPortion) -> String {
        var parts: [String] = []
        
        if let amount = portion.amount {
            // Format amount (handle fractions)
            if amount == 0.5 {
                parts.append("½")
            } else if amount == 0.25 {
                parts.append("¼")
            } else if amount == 0.75 {
                parts.append("¾")
            } else if amount == 1.5 {
                parts.append("1½")
            } else {
                let intAmount = Int(amount)
                if Double(intAmount) == amount {
                    parts.append("\(intAmount)")
                } else {
                    parts.append(String(format: "%.2f", amount))
                }
            }
        }
        
        // Add unit/modifier
        if let modifier = portion.modifier, !modifier.isEmpty {
            parts.append(modifier)
        } else if let unit = portion.measureUnit {
            if let name = unit.name, !name.isEmpty {
                parts.append(name)
            } else if let abbrev = unit.abbreviation, !abbrev.isEmpty {
                parts.append(abbrev)
            }
        }
        
        return parts.joined(separator: " ")
    }
    
}

// MARK: - Micronutrients Mapping Extension

extension FoodDefinition.Micronutrients {
    /// Initialize Micronutrients from FDC nutrients
    /// - Parameter nutrients: Array of FDCFoodNutrient from FDC API
    /// - Returns: Micronutrients with mapped values (may contain zeros if nutrients are absent)
    init(from nutrients: [FDCFoodNutrient]) {
        var fiber: Double = 0.0
        var sugar: Double = 0.0
        var sodium: Double = 0.0
        var cholesterol: Double = 0.0
        var potassium: Double = 0.0
        
        for nutrient in nutrients {
            guard let amount = nutrient.amount else { continue }
            // Allow 0 values for cholesterol (it can legitimately be 0)
            guard let nutrientInfo = nutrient.nutrient else { continue }
            
            let nutrientName = nutrientInfo.name.lowercased()
            let unitName = nutrientInfo.unitName?.uppercased() ?? ""
            let nutrientId = nutrientInfo.id
            
            // Fiber (nutrientId 1079 or name contains "fiber, total dietary")
            if nutrientId == 1079 || nutrientName.contains("fiber, total dietary") {
                if unitName == "G" || unitName.isEmpty {
                    fiber = amount
                }
            }
            // Total sugars (nutrientId 2000 or any name containing "sugar")
            else if nutrientId == 2000 ||
                    nutrientName.contains("sugars, total including") ||
                    nutrientName.contains("sugars, total") ||
                    nutrientName.contains("total sugars") ||
                    nutrientName.contains("sugar") {
                if unitName == "G" || unitName.isEmpty {
                    sugar = amount
                }
            }
            // Sodium (nutrientId 1093 or name contains "sodium, na")
            else if nutrientId == 1093 || nutrientName.contains("sodium, na") {
                if unitName == "MG" || unitName.isEmpty {
                    sodium = amount
                }
            }
            // Cholesterol (nutrientId 1253 or name contains "cholesterol")
            else if nutrientId == 1253 || nutrientName.contains("cholesterol") {
                if unitName == "MG" || unitName.isEmpty {
                    cholesterol = amount
                }
            }
            // Potassium (nutrientId 1092 or name contains "potassium, k")
            else if nutrientId == 1092 || nutrientName.contains("potassium, k") {
                if unitName == "MG" || unitName.isEmpty {
                    potassium = amount
                }
            }
        }
        
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.cholesterol = cholesterol
        self.potassium = potassium
    }
}

