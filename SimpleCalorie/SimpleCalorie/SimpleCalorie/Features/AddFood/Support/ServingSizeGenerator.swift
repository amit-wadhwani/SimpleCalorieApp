import Foundation

/// Pure logic for generating serving size presets and converting between domain units and grams.
/// No SwiftUI dependencies - can be tested independently.
struct ServingSizeGenerator {
    let food: FoodDefinition
    
    // MARK: - Public API
    
    /// Generate serving size presets (up to maxCount, default 3)
    func presets(maxCount: Int = 3) -> [FoodDefinition.ServingOption] {
        var candidates: [FoodDefinition.ServingOption] = []
        
        let baseLabel = food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)"
        let baseUnit = food.serving.unit.lowercased()
        let baseDescription = (food.serving.description ?? "").lowercased()
        let baseAmount = food.serving.amount
        
        // Determine unit domain
        let usesSliceDomain = baseDescription.contains("slice") || baseUnit.contains("slice")
        let usesCupDomain = baseDescription.contains("cup") || baseUnit.contains("cup")
        let usesTbspDomain = baseDescription.contains("tbsp") || baseUnit.contains("tbsp")
        let usesTspDomain = baseDescription.contains("tsp") || baseUnit.contains("tsp")
        let usesMlDomain = baseDescription.contains("ml") || baseUnit.contains("ml")
        
        let isEggLike = baseDescription.contains("egg")
        let isAppleLike = baseDescription.contains("apple")
        let usesPieceDomain = baseDescription.contains("piece") || baseUnit.contains("piece") || isEggLike || isAppleLike
        let usesItemDomain = baseDescription.contains("item") || baseUnit.contains("item")
        
        let isVolumeOrUnitBased = usesSliceDomain || usesCupDomain || usesTbspDomain ||
                                  usesTspDomain || usesMlDomain || usesPieceDomain || usesItemDomain
        let isGramBased = !isVolumeOrUnitBased && (baseUnit == "g" || baseUnit == "gram" || baseUnit == "grams")
        
        // Dynamic label length: allow longer labels for piece/item domains (e.g., "3 medium apples")
        let isPieceOrItemDomain = usesPieceDomain || usesItemDomain
        let maxLabelLength = isPieceOrItemDomain ? 24 : 12
        
        // Helper to check if a label matches the base unit domain
        func matchesUnitDomain(_ label: String) -> Bool {
            let labelLower = label.lowercased()
            
            if isVolumeOrUnitBased {
                var hasMatchingUnit = false
                
                if usesSliceDomain {
                    hasMatchingUnit = labelLower.contains("slice")
                } else if usesCupDomain {
                    hasMatchingUnit = labelLower.contains("cup")
                } else if usesTbspDomain {
                    hasMatchingUnit = labelLower.contains("tbsp")
                } else if usesTspDomain {
                    hasMatchingUnit = labelLower.contains("tsp")
                } else if usesMlDomain {
                    hasMatchingUnit = labelLower.contains("ml")
                } else if usesPieceDomain || usesItemDomain {
                    hasMatchingUnit = labelLower.contains("item")
                }
                
                return hasMatchingUnit && !labelLower.hasSuffix("g")
            } else if isGramBased {
                let trimmed = labelLower.trimmingCharacters(in: .whitespacesAndNewlines)
                let gramsPattern = #"^\d+\s*g$"#
                let isNumericGrams = trimmed.range(of: gramsPattern, options: .regularExpression) != nil
                let hasUnitTerm = labelLower.contains("cup") || labelLower.contains("tbsp") ||
                                  labelLower.contains("tsp") || labelLower.contains("ml") ||
                                  labelLower.contains("slice") || labelLower.contains("piece") ||
                                  labelLower.contains("item") || labelLower.contains("egg") ||
                                  labelLower.contains("apple")
                return isNumericGrams && !hasUnitTerm
            }
            
            return true
        }
        
        // Add base serving for gram-based foods
        if baseLabel.count <= maxLabelLength && isGramBased {
            candidates.append(FoodDefinition.ServingOption(
                id: UUID(),
                label: baseLabel,
                amountInGrams: baseAmount
            ))
        }
        
        // Generate conceptual presets
        if usesCupDomain {
            let conceptualUnits: [Double]
            if baseDescription.contains("1 cup") || baseDescription.contains("1c") {
                conceptualUnits = [0.5, 1.0, 1.5]
            } else if baseDescription.contains("1/2 cup") || baseDescription.contains("½ cup") || baseDescription.contains("0.5 cup") {
                conceptualUnits = [0.25, 0.5, 1.0]
            } else {
                conceptualUnits = [0.5, 1.0, 1.5]
            }
            
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                let label = unitLabel(multiplier: u, singular: "cup", plural: "cups")
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: grams
                    ))
                }
            }
        } else if usesSliceDomain {
            let conceptualUnits: [Double]
            if baseDescription.contains("1 slice") {
                conceptualUnits = [1.0, 2.0, 3.0]
            } else if baseDescription.contains("1/2 slice") || baseDescription.contains("½ slice") {
                conceptualUnits = [0.5, 1.0, 2.0]
            } else {
                conceptualUnits = [1.0, 2.0, 3.0]
            }
            
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                let label = unitLabel(multiplier: u, singular: "slice", plural: "slices")
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: grams
                    ))
                }
            }
        } else if usesTbspDomain {
            let conceptualUnits: [Double]
            if baseDescription.contains("1 tbsp") {
                conceptualUnits = [0.5, 1.0, 1.5]
            } else if baseDescription.contains("2 tbsp") {
                conceptualUnits = [1.0, 2.0, 3.0]
            } else {
                conceptualUnits = [0.5, 1.0, 1.5]
            }
            
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                let label = unitLabel(multiplier: u, singular: "tbsp", plural: "tbsp")
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: grams
                    ))
                }
            }
        } else if usesTspDomain {
            let conceptualUnits: [Double]
            if baseDescription.contains("1 tsp") {
                conceptualUnits = [0.5, 1.0, 1.5]
            } else if baseDescription.contains("2 tsp") {
                conceptualUnits = [1.0, 2.0, 3.0]
            } else {
                conceptualUnits = [0.5, 1.0, 1.5]
            }
            
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                let label = unitLabel(multiplier: u, singular: "tsp", plural: "tsp")
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: grams
                    ))
                }
            }
        } else if usesMlDomain {
            let conceptualUnits: [Double] = [1.0, 2.0, 3.0]
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                let mlValue = Int(round(grams))
                let label = "\(mlValue) ml"
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: grams
                    ))
                }
            }
        } else if usesPieceDomain || usesItemDomain {
            // Always use generic "item/items" for all piece-based foods
            let unitWordSingular = "item"
            let unitWordPlural = "items"
            
            let conceptualUnits: [Double] = [1.0, 2.0, 3.0]
            
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                let label = unitLabel(multiplier: u, singular: unitWordSingular, plural: unitWordPlural)
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: grams
                    ))
                }
            }
        } else if isGramBased {
            let gramAmounts: [Double] = [50, 100, 150, 200]
            for gramAmount in gramAmounts {
                let label = "\(Int(gramAmount))g"
                if label.count <= maxLabelLength &&
                   matchesUnitDomain(label) &&
                   !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: gramAmount
                    ))
                }
            }
        }
        
        // Add existing servingOptions that fit and match unit domain
        if let existingOptions = food.servingOptions {
            for option in existingOptions {
                if isVolumeOrUnitBased {
                    let optionLabelLower = option.label.lowercased()
                    let isGramLabel = optionLabelLower.range(of: #"^\d+\s*g$"#, options: .regularExpression) != nil
                    
                    if option.label.count <= maxLabelLength &&
                       matchesUnitDomain(option.label) &&
                       !isGramLabel &&
                       !candidates.contains(where: { $0.label == option.label }) {
                        candidates.append(option)
                    }
                } else {
                    if option.label.count <= maxLabelLength &&
                       matchesUnitDomain(option.label) &&
                       !candidates.contains(where: { $0.label == option.label }) {
                        candidates.append(option)
                    }
                }
            }
        }
        
        // Sort by amount in grams
        candidates.sort { $0.amountInGrams < $1.amountInGrams }
        
        // Normalize and deduplicate labels
        let domainForNormalization: String
        if usesCupDomain {
            domainForNormalization = "cup"
        } else if usesTbspDomain {
            domainForNormalization = "tbsp"
        } else if usesTspDomain {
            domainForNormalization = "tsp"
        } else if usesSliceDomain {
            domainForNormalization = "slice"
        } else {
            domainForNormalization = ""
        }
        
        var normalizedCandidates: [FoodDefinition.ServingOption] = []
        var seenNormalizedLabels: Set<String> = []
        for candidate in candidates {
            let normalizedLabel: String
            if !domainForNormalization.isEmpty {
                normalizedLabel = normalizeLabel(candidate.label, domain: domainForNormalization)
            } else {
                normalizedLabel = candidate.label
            }
            
            if !seenNormalizedLabels.contains(normalizedLabel) {
                normalizedCandidates.append(FoodDefinition.ServingOption(
                    id: candidate.id,
                    label: normalizedLabel,
                    amountInGrams: candidate.amountInGrams
                ))
                seenNormalizedLabels.insert(normalizedLabel)
            }
        }
        
        normalizedCandidates.sort { $0.amountInGrams < $1.amountInGrams }
        let uniqueCandidates = normalizedCandidates
        
        // Limit to maxCount presets, prioritizing base serving
        var result: [FoodDefinition.ServingOption] = []
        
        let normalizedBaseLabel = !domainForNormalization.isEmpty ? normalizeLabel(baseLabel, domain: domainForNormalization) : baseLabel
        
        // Track which candidate was used as the base (if any)
        var baseCandidateIndex: Int? = nil
        
        // First, ensure base serving is included if it exists in candidates
        if let baseIndex = uniqueCandidates.firstIndex(where: { abs($0.amountInGrams - baseAmount) < 0.1 }) {
            result.append(uniqueCandidates[baseIndex])
            baseCandidateIndex = baseIndex
        } else if let baseIndex = uniqueCandidates.firstIndex(where: { $0.label == normalizedBaseLabel }) {
            result.append(uniqueCandidates[baseIndex])
            baseCandidateIndex = baseIndex
        } else {
            result.append(FoodDefinition.ServingOption(
                id: UUID(),
                label: normalizedBaseLabel,
                amountInGrams: baseAmount
            ))
        }
        
        // Then add other candidates up to limit, skipping the base candidate
        for (index, candidate) in uniqueCandidates.enumerated() {
            if result.count >= maxCount {
                break
            }
            // Skip if this is the base candidate we already added
            if let baseIndex = baseCandidateIndex, index == baseIndex {
                continue
            }
            // Skip if label matches normalized base label (to avoid duplicates)
            if candidate.label != normalizedBaseLabel {
                result.append(candidate)
            }
        }
        
        // Sort result by amountInGrams
        result.sort { $0.amountInGrams < $1.amountInGrams }
        
        return result
    }
    
    /// Convert domain units to grams
    func domainUnitsToGrams(_ domainUnits: Double) -> Double {
        if isGramBaseDomain {
            return domainUnits
        }
        return domainUnits * gramsPerDomainUnit
    }
    
    /// Convert grams to domain units
    func gramsToDomainUnits(_ grams: Double) -> Double {
        if isGramBaseDomain || gramsPerDomainUnit == 0 {
            return grams
        }
        return grams / gramsPerDomainUnit
    }
    
    /// Format custom label for given grams
    func formatCustomLabel(forGrams grams: Double) -> String {
        if grams <= 0 {
            return "Custom"
        }
        
        guard let unit = customDisplayUnit else {
            return "\(Int(grams))g"
        }
        
        let conceptualUnits = grams / gramsPerDomainUnit
        
        if conceptualUnits > 0 {
            return unitLabel(multiplier: conceptualUnits, singular: unit.singular, plural: unit.plural)
        } else {
            return "\(Int(grams))g"
        }
    }
    
    /// Whether Custom serving should be shown
    var canShowCustom: Bool {
        return customDisplayUnit != nil || isGramBaseDomain
    }
    
    /// Grams per 1 domain unit
    var gramsPerDomainUnit: Double {
        if isGramBaseDomain {
            return 1.0
        }
        
        let baseUnits = parsedBaseUnitsFromDescription()
        guard baseUnits > 0 else { return food.serving.amount }
        
        let gramsPerUnit = food.serving.amount / baseUnits
        
        #if DEBUG
        let expectedAmount = gramsPerUnit * baseUnits
        assert(abs(expectedAmount - food.serving.amount) < 0.1,
               "gramsPerDomainUnit consistency check failed: \(gramsPerUnit) * \(baseUnits) = \(expectedAmount), expected \(food.serving.amount)")
        #endif
        
        return gramsPerUnit
    }
    
    /// Debug description for serving diagnostics
    var debugDescription: String {
        let baseDescription = (food.serving.description ?? "").lowercased()
        let baseUnit = food.serving.unit.lowercased()
        
        var domainType = "unknown"
        if baseDescription.contains("cup") || baseUnit.contains("cup") {
            domainType = "cup"
        } else if baseDescription.contains("tbsp") || baseUnit.contains("tbsp") {
            domainType = "tbsp"
        } else if baseDescription.contains("slice") || baseUnit.contains("slice") {
            domainType = "slice"
        } else if baseDescription.contains("egg") {
            domainType = "piece (egg)"
        } else if baseDescription.contains("apple") {
            domainType = "piece (apple)"
        } else if baseDescription.contains("piece") || baseUnit.contains("piece") {
            domainType = "piece"
        } else if isGramBaseDomain {
            domainType = "grams"
        }
        
        let presets = self.presets(maxCount: 3)
        let presetLines = presets.map { "  - \($0.label) = \(Int($0.amountInGrams))g" }.joined(separator: "\n")
        
        return """
        Domain: \(domainType)
        Base: "\(food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)")", grams: \(Int(food.serving.amount))
        gramsPerDomainUnit: \(String(format: "%.1f", gramsPerDomainUnit))
        Presets:
        \(presetLines)
        """
    }
    
    // MARK: - Private Helpers
    
    private var isGramBaseDomain: Bool {
        let baseUnit = food.serving.unit.lowercased()
        let baseDescription = (food.serving.description ?? "").lowercased()
        
        let isPieceBased = baseDescription.contains("egg") || baseDescription.contains("apple") ||
                          baseDescription.contains("piece") || baseDescription.contains("item")
        let isVolumeBased = baseDescription.contains("cup") || baseDescription.contains("slice") ||
                           baseDescription.contains("tbsp") || baseDescription.contains("tsp") ||
                           baseDescription.contains("ml")
        
        return (baseUnit == "g" || baseUnit == "gram" || baseUnit == "grams") && !isPieceBased && !isVolumeBased
    }
    
    private func parsedBaseUnitsFromDescription() -> Double {
        let desc = (food.serving.description ?? "").lowercased()
        
        // Handle ASCII fractions first (before unicode and regex)
        // This ensures "1/2 cup dry" is parsed as 0.5, not 1.0
        if desc.contains("1/2") { return 0.5 }
        if desc.contains("1/4") { return 0.25 }
        if desc.contains("3/4") { return 0.75 }
        
        // Handle unicode fractions
        if desc.contains("½") { return 0.5 }
        if desc.contains("¼") { return 0.25 }
        if desc.contains("¾") { return 0.75 }
        
        // Handle other "num/den" styles via regex (fallback for other fractions)
        if let range = desc.range(of: #"(\d+)\s*/\s*(\d+)"#, options: .regularExpression) {
            let frac = String(desc[range])
            let parts = frac.split(separator: "/")
            if parts.count == 2, let num = Double(parts[0]), let den = Double(parts[1]), den != 0 {
                return num / den
            }
        }
        
        // Handle first integer
        if let range = desc.range(of: #"\d+"#, options: .regularExpression) {
            let numStr = String(desc[range])
            if let num = Double(numStr) {
                return num
            }
        }
        
        return 1.0
    }
    
    private var customDisplayUnit: (singular: String, plural: String)? {
        let baseDescription = (food.serving.description ?? "").lowercased()
        let baseUnit = food.serving.unit.lowercased()
        
        if baseDescription.contains("cup") || baseUnit.contains("cup") {
            return ("cup", "cups")
        } else if baseDescription.contains("slice") || baseUnit.contains("slice") {
            return ("slice", "slices")
        } else if baseDescription.contains("tbsp") || baseUnit.contains("tbsp") {
            return ("tbsp", "tbsp")
        } else if baseDescription.contains("tsp") || baseUnit.contains("tsp") {
            return ("tsp", "tsp")
        } else if baseDescription.contains("ml") || baseUnit.contains("ml") {
            return ("ml", "ml")
        } else if baseDescription.contains("egg") || baseDescription.contains("apple") || 
                  baseDescription.contains("piece") || baseUnit.contains("piece") ||
                  baseDescription.contains("item") || baseUnit.contains("item") {
            // All piece-based foods use generic "item/items"
            return ("item", "items")
        }
        return nil
    }
    
    private func unitLabel(multiplier: Double, singular: String, plural: String) -> String {
        if multiplier == 0.25 {
            return "¼ \(singular)"
        } else if multiplier == 0.5 {
            return "½ \(singular)"
        } else if multiplier == 0.75 {
            return "¾ \(singular)"
        } else if multiplier == 1.0 {
            return "1 \(singular)"
        } else if multiplier == 1.5 {
            return "1½ \(plural)"
        } else if multiplier == 1.25 {
            return "1¼ \(plural)"
        } else if multiplier == 1.75 {
            return "1¾ \(plural)"
        } else {
            let count = Int(round(multiplier))
            return "\(count) \(plural)"
        }
    }
    
    private func normalizeLabel(_ label: String, domain: String) -> String {
        let descriptors = [" dry", " cooked", " raw", " boiled", " chopped", " diced", " sliced", " whole", " large", " medium", " small"]
        var normalized = label
        for descriptor in descriptors {
            normalized = normalized.replacingOccurrences(of: descriptor, with: "", options: .caseInsensitive)
        }
        
        if domain == "cup" {
            normalized = normalized.replacingOccurrences(of: "cups", with: "cup", options: .caseInsensitive)
            if let amountMatch = normalized.range(of: #"(\d+|\d+\.\d+|¼|½|¾|1½|1¼|1¾)\s*cup"#, options: .regularExpression) {
                let amountStr = String(normalized[amountMatch])
                if amountStr.contains("1 ") && !amountStr.contains("1½") && !amountStr.contains("1¼") && !amountStr.contains("1¾") {
                    return "1 cup"
                } else if amountStr.contains("1½") {
                    return "1½ cups"
                } else if amountStr.contains("1¼") {
                    return "1¼ cups"
                } else if amountStr.contains("1¾") {
                    return "1¾ cups"
                } else {
                    if let numMatch = amountStr.range(of: #"\d+"#, options: .regularExpression) {
                        let numStr = String(amountStr[numMatch])
                        if let num = Int(numStr), num > 1 {
                            return "\(num) cups"
                        }
                    }
                    return normalized.trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        if domain == "tbsp" {
            normalized = normalized.replacingOccurrences(of: "tablespoon", with: "tbsp", options: .caseInsensitive)
            normalized = normalized.replacingOccurrences(of: "tablespoons", with: "tbsp", options: .caseInsensitive)
        }
        if domain == "tsp" {
            normalized = normalized.replacingOccurrences(of: "teaspoon", with: "tsp", options: .caseInsensitive)
            normalized = normalized.replacingOccurrences(of: "teaspoons", with: "tsp", options: .caseInsensitive)
        }
        
        if domain == "slice" {
            normalized = normalized.replacingOccurrences(of: "slices", with: "slice", options: .caseInsensitive)
            if let amountMatch = normalized.range(of: #"(\d+)\s*slice"#, options: .regularExpression) {
                let amountStr = String(normalized[amountMatch])
                if let numMatch = amountStr.range(of: #"\d+"#, options: .regularExpression) {
                    let numStr = String(amountStr[numMatch])
                    if let num = Int(numStr) {
                        return num == 1 ? "1 slice" : "\(num) slices"
                    }
                }
            }
        }
        
        return normalized.trimmingCharacters(in: .whitespaces)
    }
    
    /// Parse and snap custom amount to quarter increments
    func parseAndSnapCustomAmount(_ text: String) -> Double? {
        guard let raw = Double(text), raw >= 0.25 else { return nil }
        let snapped = (raw * 4.0).rounded() / 4.0
        return snapped
    }
}

