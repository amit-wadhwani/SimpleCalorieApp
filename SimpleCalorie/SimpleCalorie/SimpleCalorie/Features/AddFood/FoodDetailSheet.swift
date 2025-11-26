import SwiftUI

struct FoodDetailSheet: View {
    let food: FoodDefinition
    @Binding var state: AddFoodViewModel.FoodDetailState
    let meal: MealType
    
    let onServingSizeTap: (FoodDefinition.ServingOption) -> Void
    let onDefaultServingTap: () -> Void
    let onCustomServingCommit: (Double) -> Void
    let onQuantityChange: (Double) -> Void
    let onWeekdayToggle: (Weekday) -> Void
    let onDateToggle: (Date) -> Void
    let onRecurringToggle: () -> Void
    let onAdd: (MealType) -> Void
    let onCancel: () -> Void
    let onFavoriteToggle: () -> Void
    let onRecurringEndDateChange: (Date) -> Void
    
    let servingGenerator: ServingSizeGenerator
    
    @State private var isFavorite: Bool
    @State private var showFullNutrition: Bool = false
    @State private var customAmountText: String = ""
    @State private var quantityText: String = "1.0"
    @State private var isCustomAmountActive: Bool = false
    @State private var showEndDatePicker: Bool = false
    @State private var previousCalories: Double = 0
    @State private var shouldAnimateDonut: Bool = false
    #if DEBUG
    @State private var showServingDebug: Bool = false
    #endif
    @FocusState private var isCustomAmountFocused: Bool
    @FocusState private var isQuantityFocused: Bool
    
    @AppStorage(DetailSheetLayoutVariant.storageKey) private var layoutVariantRaw: String = DetailSheetLayoutVariant.controlsAbove.rawValue
    @AppStorage(HeartStyleVariant.storageKey) private var heartVariantRaw: String = HeartStyleVariant.flat.rawValue
    @AppStorage("nutrition.macroLabelsUppercase") private var macroLabelsUppercase: Bool = true
    
    private var layoutVariant: DetailSheetLayoutVariant {
        DetailSheetLayoutVariant(rawValue: layoutVariantRaw) ?? .controlsAbove
    }
    
    private var heartVariant: HeartStyleVariant {
        HeartStyleVariant(rawValue: heartVariantRaw) ?? .flat
    }
    
    // Date sequence for weekday/date alignment
    // Uses state.baseDate to ensure stable alignment (doesn't shift when toggling recurring)
    private var dateSequence: [Date] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: state.baseDate)
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: baseDate)
        }
    }
    
    // Weekday formatter for alignment
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    // Computed properties for scaled macros
    private var baseGrams: Double {
        if let option = state.selectedServing {
            return option.amountInGrams
        } else {
            return food.serving.amount
        }
    }
    
    private var effectiveGrams: Double {
        state.customAmountInGrams ?? baseGrams
    }
    
    private var servingMultiplier: Double {
        (effectiveGrams / food.serving.amount) * state.quantity
    }
    
    private var scaledCalories: Int {
        Int((Double(food.macros.calories) * servingMultiplier).rounded())
    }
    
    private var scaledProtein: Double {
        food.macros.protein * servingMultiplier
    }
    
    private var scaledCarbs: Double {
        food.macros.carbs * servingMultiplier
    }
    
    private var scaledFat: Double {
        food.macros.fat * servingMultiplier
    }
    
    private var totalMacros: Double {
        scaledProtein + scaledCarbs + scaledFat
    }
    
    // Display serving options - delegate to ServingSizeGenerator
    private var displayServingOptions: [FoodDefinition.ServingOption] {
        servingGenerator.presets(maxCount: 3)
    }
    
    // MARK: - Legacy displayServingOptions implementation (removed - now uses ServingSizeGenerator)
    /*
    internal var displayServingOptions_OLD: [FoodDefinition.ServingOption] {
        let maxLabelLength = 12
        var candidates: [FoodDefinition.ServingOption] = []
        
        // Base serving (always include if it fits)
        let baseLabel = food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)"
        let baseUnit = food.serving.unit.lowercased()
        let baseDescription = (food.serving.description ?? "").lowercased()
        let baseAmount = food.serving.amount
        
        // Extract the actual unit word from description if present, otherwise use unit field
        // For "1 cup", extract "cup"; for "2 tbsp", extract "tbsp"
        func extractUnitWord(from description: String) -> String? {
            let descLower = description.lowercased()
            let unitWords = ["cup", "cups", "slice", "slices", "tbsp", "tsp", "ml", "piece", "pieces", "item", "items"]
            for word in unitWords {
                if descLower.contains(word) {
                    // Return singular form
                    if word.hasSuffix("s") && word.count > 1 {
                        return String(word.dropLast())
                    }
                    return word
                }
            }
            return nil
        }
        
        let _ = extractUnitWord(from: baseDescription) ?? baseUnit
        // Extracted unit is used implicitly in unitLabel calls via domain detection
        
        // Determine unit domain - prioritize description over unit field
        let usesSliceDomain = baseDescription.contains("slice") || baseUnit.contains("slice")
        let usesCupDomain = baseDescription.contains("cup") || baseUnit.contains("cup")
        let usesTbspDomain = baseDescription.contains("tbsp") || baseUnit.contains("tbsp")
        let usesTspDomain = baseDescription.contains("tsp") || baseUnit.contains("tsp")
        let usesMlDomain = baseDescription.contains("ml") || baseUnit.contains("ml")
        
        // Recognize common piece-based foods (egg, apple, etc.)
        let isEggLike = baseDescription.contains("egg")
        let isAppleLike = baseDescription.contains("apple")
        let usesPieceDomain = baseDescription.contains("piece") || baseUnit.contains("piece") || isEggLike || isAppleLike
        let usesItemDomain = baseDescription.contains("item") || baseUnit.contains("item")
        
        // Only consider gram-based if NOT volume/unit-based (to avoid conflicts)
        // Note: isEggLike and isAppleLike are already included in usesPieceDomain
        let isVolumeOrUnitBased = usesSliceDomain || usesCupDomain || usesTbspDomain || 
                                  usesTspDomain || usesMlDomain || usesPieceDomain || usesItemDomain
        let isGramBased = !isVolumeOrUnitBased && (baseUnit == "g" || baseUnit == "gram" || baseUnit == "grams")
        
        // Helper to check if a label matches the base unit domain
        func matchesUnitDomain(_ label: String) -> Bool {
            let labelLower = label.lowercased()
            
            if isVolumeOrUnitBased {
                // For volume/unit-based, check if label contains the same unit type
                // AND exclude any labels ending with "g" (gram-based)
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
                } else if usesPieceDomain {
                    hasMatchingUnit = labelLower.contains("piece")
                } else if usesItemDomain {
                    hasMatchingUnit = labelLower.contains("item")
                }
                
                // Exclude gram-based labels (must not end with "g")
                return hasMatchingUnit && !labelLower.hasSuffix("g")
            } else if isGramBased {
                // For gram-based, only include labels that look like "100g" or "150 g" (number + optional space + "g")
                // This prevents "egg" or "apple" from being treated as grams
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
            
            return true // Fallback: include if we can't determine
        }
        
        // Add base serving if it fits
        // Skip adding baseLabel as-is if we are in tbsp/tsp domain;
        // the conceptual presets will cover it to ensure strict ordering
        // Also skip if baseLabel looks like a gram label (e.g., "50g") for piece-based foods
        // For unit-based domains, the base will be covered by conceptual presets, so we don't need to add it separately
        // Only add base for gram-based or if it's truly needed
        if baseLabel.count <= maxLabelLength && isGramBased {
            // For gram-based, add the base serving
            candidates.append(FoodDefinition.ServingOption(
                id: UUID(),
                label: baseLabel,
                amountInGrams: baseAmount
            ))
        }
        // For unit-based domains (cups, slices, tbsp, tsp, ml, pieces), the conceptual presets will cover the base
        
        // Generate fractional/multiple presets (only if matching unit domain)
        // Use gramsPerDomainUnit * conceptualUnits for consistency with Custom
        if usesCupDomain {
            // For cup-based servings, use conceptual units
            let conceptualUnits: [Double]
            if baseDescription.contains("1 cup") || baseDescription.contains("1c") {
                // Base is ~1 cup: show ½, 1, 1½
                conceptualUnits = [0.5, 1.0, 1.5]
            } else if baseDescription.contains("1/2 cup") || baseDescription.contains("½ cup") || baseDescription.contains("0.5 cup") {
                // Base is ~0.5 cup: show ¼, ½, 1
                conceptualUnits = [0.25, 0.5, 1.0]
            } else {
                // Fallback: show 0.5, 1, 1.5
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
            // For slice-based servings, use conceptual units
            let conceptualUnits: [Double]
            if baseDescription.contains("1 slice") {
                // Base is ~1 slice: show 1, 2, 3
                conceptualUnits = [1.0, 2.0, 3.0]
            } else if baseDescription.contains("1/2 slice") || baseDescription.contains("½ slice") {
                // Base is ~0.5 slice: show ½, 1, 2
                conceptualUnits = [0.5, 1.0, 2.0]
            } else {
                // Fallback: show 1, 2, 3
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
            // For tbsp-based servings, use conceptual units
            let conceptualUnits: [Double]
            if baseDescription.contains("1 tbsp") {
                // Base is ~1 tbsp: show 0.5, 1, 1.5
                conceptualUnits = [0.5, 1.0, 1.5]
            } else if baseDescription.contains("2 tbsp") {
                // Base is ~2 tbsp: show 1, 2, 3
                conceptualUnits = [1.0, 2.0, 3.0]
            } else {
                // Fallback: show 0.5, 1, 1.5
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
            // For tsp-based servings, use conceptual units
            let conceptualUnits: [Double]
            if baseDescription.contains("1 tsp") {
                // Base is ~1 tsp: show 0.5, 1, 1.5
                conceptualUnits = [0.5, 1.0, 1.5]
            } else if baseDescription.contains("2 tsp") {
                // Base is ~2 tsp: show 1, 2, 3
                conceptualUnits = [1.0, 2.0, 3.0]
            } else {
                // Fallback: show 0.5, 1, 1.5
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
            // For ml-based servings: use simple integer steps (no fractions)
            // Conceptual units: 1x, 2x, 3x
            let conceptualUnits: [Double] = [1.0, 2.0, 3.0]
            for u in conceptualUnits {
                let grams = gramsPerDomainUnit * u
                // For ml, use integer values only
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
            // For piece/item-based servings
            // Choose smarter unit words based on the food type
            let unitWordSingular: String
            let unitWordPlural: String
            
            if isEggLike {
                unitWordSingular = "large egg"
                unitWordPlural = "large eggs"
            } else if isAppleLike {
                unitWordSingular = "medium apple"
                unitWordPlural = "medium apples"
            } else {
                let unitWord = usesPieceDomain ? "piece" : "item"
                unitWordSingular = unitWord
                unitWordPlural = unitWord + "s"
            }
            
            // Always show 1, 2, 3 regardless of base (if base is 2, still show 1, 2, 3)
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
            // For gram-based, generate 50g, 100g, 150g, 200g variants
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
        
        // Add any existing servingOptions that fit and match unit domain
        // IMPORTANT: Only add if they match the detected domain (no gram options for unit-based foods)
        if let existingOptions = food.servingOptions {
            for option in existingOptions {
                // For unit-based foods, exclude any gram-based options from servingOptions
                if isVolumeOrUnitBased {
                    // Only include if it matches the unit domain (not grams)
                    // For piece-based foods, also exclude gram labels
                    let optionLabelLower = option.label.lowercased()
                    let isGramLabel = optionLabelLower.range(of: #"^\d+\s*g$"#, options: .regularExpression) != nil
                    
                    if option.label.count <= maxLabelLength && 
                       matchesUnitDomain(option.label) &&
                       !isGramLabel &&
                       !candidates.contains(where: { $0.label == option.label }) {
                        candidates.append(option)
                    }
                } else {
                    // For gram-based foods, include gram options
                    if option.label.count <= maxLabelLength && 
                       matchesUnitDomain(option.label) &&
                       !candidates.contains(where: { $0.label == option.label }) {
                        candidates.append(option)
                    }
                }
            }
        }
        
        // Sort by amount in grams (increasing order)
        candidates.sort { $0.amountInGrams < $1.amountInGrams }
        
        // Normalize and deduplicate labels
        // First, determine the domain for normalization
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
        
        // Normalize all labels and deduplicate
        var normalizedCandidates: [FoodDefinition.ServingOption] = []
        var seenNormalizedLabels: Set<String> = []
        for candidate in candidates {
            let normalizedLabel: String
            if !domainForNormalization.isEmpty {
                // Normalize the label (remove "dry", "cooked", etc.)
                normalizedLabel = normalizeLabel(candidate.label, domain: domainForNormalization)
            } else {
                // For gram-based or other domains, use label as-is
                normalizedLabel = candidate.label
            }
            
            // Only add if we haven't seen this normalized label before
            if !seenNormalizedLabels.contains(normalizedLabel) {
                normalizedCandidates.append(FoodDefinition.ServingOption(
                    id: candidate.id,
                    label: normalizedLabel,
                    amountInGrams: candidate.amountInGrams
                ))
                seenNormalizedLabels.insert(normalizedLabel)
            }
        }
        
        // Re-sort after normalization (amounts may have changed slightly)
        normalizedCandidates.sort { $0.amountInGrams < $1.amountInGrams }
        
        // Use normalized candidates
        let uniqueCandidates = normalizedCandidates
        
        // Limit to 3 presets, prioritizing base serving
        var result: [FoodDefinition.ServingOption] = []
        
        // Normalize base label for comparison
        // For cup domain, ensure "½ cup dry" and "½ cup cooked" both normalize to "½ cup"
        let normalizedBaseLabel = !domainForNormalization.isEmpty ? normalizeLabel(baseLabel, domain: domainForNormalization) : baseLabel
        
        // First, ensure base serving is included if it exists in candidates
        // Use grams comparison with tolerance to handle normalized labels and rounding
        if let baseIndex = uniqueCandidates.firstIndex(where: { abs($0.amountInGrams - baseAmount) < 0.1 }) {
            result.append(uniqueCandidates[baseIndex])
        } else if let baseIndex = uniqueCandidates.firstIndex(where: { $0.label == normalizedBaseLabel }) {
            // Fallback to label match if grams don't match (shouldn't happen, but safe)
            result.append(uniqueCandidates[baseIndex])
        } else {
            // If base serving wasn't in candidates (e.g., label too long), add it anyway with normalized label
            // This ensures base serving is always available
            result.append(FoodDefinition.ServingOption(
                id: UUID(),
                label: normalizedBaseLabel,
                amountInGrams: baseAmount
            ))
        }
        
        // Then add other candidates up to limit of 3
        for candidate in uniqueCandidates {
            if result.count >= 3 {
                break
            }
            if candidate.label != normalizedBaseLabel {
                result.append(candidate)
            }
        }
        
        // Sort result by amountInGrams to ensure strictly increasing order
        result.sort { $0.amountInGrams < $1.amountInGrams }
        
        return result
    }
    */
    
    // MARK: - Removed helpers (now in ServingSizeGenerator)
    // unitLabel, normalizeLabel, isGramBaseDomain, parsedBaseUnitsFromDescription,
    // gramsPerDomainUnit, domainUnitsToGrams, gramsToDomainUnits, customDisplayUnit,
    // shouldShowCustomServing, formatCustomAmountLabel, parseAndSnapCustomAmount
    
    // MARK: - Wrapper methods for ServingSizeGenerator
    
    private var isGramBaseDomain: Bool {
        // Check if domain is gram-based (not piece/volume-based)
        let baseUnit = food.serving.unit.lowercased()
        let baseDescription = (food.serving.description ?? "").lowercased()
        
        let isPieceBased = baseDescription.contains("egg") || baseDescription.contains("apple") ||
                          baseDescription.contains("piece") || baseDescription.contains("item")
        let isVolumeBased = baseDescription.contains("cup") || baseDescription.contains("slice") ||
                           baseDescription.contains("tbsp") || baseDescription.contains("tsp") ||
                           baseDescription.contains("ml")
        
        return (baseUnit == "g" || baseUnit == "gram" || baseUnit == "grams") && !isPieceBased && !isVolumeBased
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
        } else if baseDescription.contains("egg") {
            return ("large egg", "large eggs")
        } else if baseDescription.contains("apple") {
            return ("medium apple", "medium apples")
        } else if baseDescription.contains("piece") || baseUnit.contains("piece") {
            return ("piece", "pieces")
        } else if baseDescription.contains("item") || baseUnit.contains("item") {
            return ("item", "items")
        }
        return nil
    }
    
    private var shouldShowCustomServing: Bool {
        servingGenerator.canShowCustom
    }
    
    private func formatCustomAmountLabel(grams: Double) -> String {
        servingGenerator.formatCustomLabel(forGrams: grams)
    }
    
    private func domainUnitsToGrams(_ domainUnits: Double) -> Double {
        servingGenerator.domainUnitsToGrams(domainUnits)
    }
    
    private func gramsToDomainUnits(_ grams: Double) -> Double {
        servingGenerator.gramsToDomainUnits(grams)
    }
    
    private func parseAndSnapCustomAmount(_ text: String) -> Double? {
        servingGenerator.parseAndSnapCustomAmount(text)
    }
    
    // Is custom serving selected
    private var isCustomServingSelected: Bool {
        state.customAmountInGrams != nil
    }
    
    // Format domain units for TextField display
    private func formatDomainUnitsForInput(_ domainUnits: Double) -> String {
        // Show integer if whole number, otherwise show up to 2 decimal places
        if domainUnits.truncatingRemainder(dividingBy: 1.0) == 0 {
            return String(Int(domainUnits))
        } else {
            // Round to 2 decimal places for display, remove trailing zeros
            let rounded = (domainUnits * 100).rounded() / 100
            let formatted = String(format: "%.2f", rounded)
            // Remove trailing zeros and decimal point if needed
            if formatted.hasSuffix(".00") {
                return String(Int(rounded))
            } else if formatted.hasSuffix("0") {
                return String(format: "%.1f", rounded)
            } else {
                return formatted
            }
        }
    }
    
    // Determine if a serving option is selected (using label-based equality)
    private func isServingOptionSelected(_ option: FoodDefinition.ServingOption) -> Bool {
        if isCustomServingSelected {
            return false
        }
        
        if let selectedServing = state.selectedServing {
            // Compare by grams, not just label, to be robust (handles normalized labels)
            return abs(option.amountInGrams - selectedServing.amountInGrams) < 0.01
        } else {
            // No selectedServing means we're on the base
            let baseAmount = food.serving.amount
            return abs(option.amountInGrams - baseAmount) < 0.01
        }
    }
    
    // CTA enabled state
    private var isAddButtonEnabled: Bool {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())
        
        if state.isRecurring {
            // Recurring mode: need weekdays and valid end date
            guard !state.selectedWeekdays.isEmpty,
                  let endDate = state.recurringEndDate else {
                return false
            }
            // End date must be on or after base date
            return calendar.startOfDay(for: endDate) >= baseDate
        } else {
            // Day mode: need at least one selected date
            return !state.selectedDates.isEmpty
        }
    }
    
    // Recurring end date formatter
    private var endDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var endDateString: String {
        guard let endDate = state.recurringEndDate else { return "" }
        return endDateFormatter.string(from: endDate)
    }
    
    init(
        food: FoodDefinition,
        state: Binding<AddFoodViewModel.FoodDetailState>,
        meal: MealType,
        isFavorite: Bool,
        onServingSizeTap: @escaping (FoodDefinition.ServingOption) -> Void,
        onDefaultServingTap: @escaping () -> Void,
        onCustomServingCommit: @escaping (Double) -> Void,
        onQuantityChange: @escaping (Double) -> Void,
        onWeekdayToggle: @escaping (Weekday) -> Void,
        onDateToggle: @escaping (Date) -> Void,
        onRecurringToggle: @escaping () -> Void,
        onAdd: @escaping (MealType) -> Void,
        onCancel: @escaping () -> Void,
        onFavoriteToggle: @escaping () -> Void,
        onRecurringEndDateChange: @escaping (Date) -> Void
    ) {
        self.food = food
        self._state = state
        self.meal = meal
        self.servingGenerator = ServingSizeGenerator(food: food)
        self._isFavorite = State(initialValue: isFavorite)
        self.onServingSizeTap = onServingSizeTap
        self.onDefaultServingTap = onDefaultServingTap
        self.onCustomServingCommit = onCustomServingCommit
        self.onQuantityChange = onQuantityChange
        self.onWeekdayToggle = onWeekdayToggle
        self.onDateToggle = onDateToggle
        self.onRecurringToggle = onRecurringToggle
        self.onAdd = onAdd
        self.onCancel = onCancel
        self.onFavoriteToggle = onFavoriteToggle
        self.onRecurringEndDateChange = onRecurringEndDateChange
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header: Food name, subtitle, heart
                    headerSection
                        .padding(.bottom, AppSpace.s16)
                    
                    // Hero Nutrition Card (Figma-style)
                    heroNutritionCard
                        .padding(.bottom, AppSpace.md)
                    
                    // Serving Size Card
                    servingSizeCard
                        .padding(.bottom, AppSpace.md)
                    
                    // Quantity Card
                    quantityCard
                        .padding(.bottom, AppSpace.md)
                    
                    // Schedule Card
                    scheduleCard
                    
                    Spacer(minLength: 100)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Dismiss focus for both custom and quantity fields when tapping outside
                    if isCustomAmountFocused {
                        isCustomAmountFocused = false
                    }
                    if isQuantityFocused {
                        isQuantityFocused = false
                    }
                }
                .padding(.horizontal, AppSpace.s16)
                .padding(.top, AppSpace.s12)
            }
            .background(AppColor.bgScreen)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(AppColor.brandPrimary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomActions
            }
            .sheet(isPresented: $showEndDatePicker) {
                endDatePickerSheet
            }
            .onAppear {
                quantityText = formatQuantity(state.quantity)
                previousCalories = Double(scaledCalories)
            }
            .onChange(of: scaledCalories) { oldValue, newValue in
                let oldCal = previousCalories
                let newCal = Double(newValue)
                let changePercent = abs(newCal - oldCal) / max(oldCal, 1)
                shouldAnimateDonut = changePercent > 0.10
                previousCalories = newCal
            }
            .onChange(of: state.customAmountInGrams) { _, newValue in
                // Only collapse Custom when we're NOT actively editing.
                if newValue == nil && !isCustomAmountFocused {
                    isCustomAmountActive = false
                    customAmountText = ""
                }
            }
            .onChange(of: isCustomAmountFocused) { _, isFocused in
                // Commit custom amount when focus is lost
                if !isFocused && isCustomAmountActive {
                    commitCustomAmount()
                }
            }
            .onChange(of: state.quantity) { _, newValue in
                if !isQuantityFocused {
                    quantityText = formatQuantity(newValue)
                }
            }
        }
    }
    
    // MARK: - Hero Nutrition Card (Variation 4 - Minimal & Centered)
    
    private var heroNutritionCard: some View {
        VStack(spacing: AppSpace.s16) {
            // Row 1: Centered Donut with Calories inside
            VStack(spacing: 4) {
                ZStack {
                    donutChart
                        .frame(width: 110, height: 110)
                    
                    // Calories centered inside donut
                    VStack(spacing: 2) {
                        Text("\(scaledCalories)")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(AppColor.textTitle)
                        
                        Text("kcal")
                            .font(.subheadline)
                            .foregroundStyle(AppColor.textMuted)
                    }
                }
            }
            
            // Row 2: Macro grid (3 columns)
            HStack(spacing: AppSpace.sm) {
                macroColumn(label: "Protein", value: formatMacro(scaledProtein), color: AppColor.macroProtein)
                macroColumn(label: "Carbs", value: formatMacro(scaledCarbs), color: AppColor.macroCarbs)
                macroColumn(label: "Fat", value: formatMacro(scaledFat), color: AppColor.macroFat)
            }
            
            // Row 3: View Full Nutrition (inside hero card)
            fullNutritionRow
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpace.s12)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func macroColumn(label: String, value: String, color: Color) -> some View {
        let displayLabel = macroLabelsUppercase ? label.uppercased() : label
        let percentage = totalMacros > 0 ? Int((getMacroValue(label: label) / totalMacros) * 100) : 0
        
        return VStack(spacing: 4) {
            // Macro name
            Text(displayLabel)
                .font(.footnote)
                .foregroundStyle(AppColor.textMuted)
            
            // Macro value
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
            
            // Percentage (optional, lighter font)
            Text("\(percentage)%")
                .font(.caption)
                .foregroundStyle(AppColor.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getMacroValue(label: String) -> Double {
        switch label.lowercased() {
        case "protein": return scaledProtein
        case "carbs": return scaledCarbs
        case "fat": return scaledFat
        default: return 0
        }
    }
    
    private var fullNutritionRow: some View {
        VStack(spacing: AppSpace.sm) {
            // Centered, muted gray underlined link row
            Button {
                withAnimation {
                    showFullNutrition.toggle()
                }
                Haptics.light()
            } label: {
                HStack(spacing: 4) {
                    Text("View Full Nutrition")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textMuted.opacity(0.7))
                        .underline()
                    
                    Image(systemName: showFullNutrition ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColor.textMuted)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            
            // Micronutrient list when expanded
            if showFullNutrition {
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    nutritionRow(label: "Fiber", value: "0g")
                    nutritionRow(label: "Sugar", value: "0g")
                    nutritionRow(label: "Sodium", value: "0mg")
                    nutritionRow(label: "Cholesterol", value: "0mg")
                    nutritionRow(label: "Potassium", value: "0mg")
                }
                .padding(.top, AppSpace.sm)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppColor.textTitle)
                    
                    // Brand or "Generic" subtitle
                    let subtitle = food.brand ?? "Generic"
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(AppColor.textMuted)
                }
                
                Spacer()
                
                // Heart button with style variant
                heartButton
            }
        }
    }
    
    private var heartButton: some View {
        Button {
            isFavorite.toggle()
            onFavoriteToggle()
            Haptics.light()
        } label: {
            if heartVariant == .flat {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(isFavorite ? .red : AppColor.textMuted)
            } else {
                // Pill style
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.subheadline)
                        .foregroundStyle(isFavorite ? .red : AppColor.textMuted)
                }
                .frame(width: 32, height: 32)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Serving Size Card
    
    private var servingSizeCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.s12) {
            HStack {
                Text("Serving Size")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                #if DEBUG
                Button {
                    showServingDebug.toggle()
                } label: {
                    Text("Debug")
                        .font(.caption2)
                        .foregroundStyle(AppColor.textMuted)
                }
                .buttonStyle(.plain)
                #endif
            }
            
            HStack(spacing: AppSpace.sm) {
                // Display serving options (includes base serving, max 3)
                // Use label as id for stable equality checks
                ForEach(displayServingOptions, id: \.label) { option in
                    servingChip(
                        label: option.label,
                        isSelected: isServingOptionSelected(option),
                        action: { onServingSizeTap(option) }
                    )
                }
                
                // Custom chip (always last, stable position) - only show if domain is understood
                if shouldShowCustomServing {
                    customServingChip
                }
            }
            
            #if DEBUG
            if showServingDebug {
                VStack(alignment: .leading, spacing: 4) {
                    Text(servingGenerator.debugDescription)
                        .font(.caption2)
                        .foregroundStyle(AppColor.textMuted)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.04))
                        )
                }
                .padding(.top, AppSpace.sm)
            }
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpace.sm)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
            .fill(AppColor.bgCard)
        )
    }
    
    // MARK: - Quantity Card
    
    private var quantityCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.s12) {
            // Label left-aligned
            Text("Quantity")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.textTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Controls centered horizontally
            HStack {
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        let newValue = max(0.1, state.quantity - 1)
                        onQuantityChange(newValue)
                        quantityText = formatQuantity(newValue)
                        Haptics.light()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColor.textTitle.opacity(state.quantity > 1 ? 1 : 0.4))
                    }
                    .buttonStyle(.plain)
                    .disabled(state.quantity <= 1)
                    
                    TextField("", text: $quantityText)
                        .keyboardType(.decimalPad)
                        .focused($isQuantityFocused)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.textTitle)
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                        .onChange(of: quantityText) { _, newValue in
                            if newValue.isEmpty {
                                return
                            }
                            if let value = Double(newValue) {
                                let rounded = (value * 100).rounded() / 100
                                if rounded > 0 {
                                    onQuantityChange(rounded)
                                }
                            }
                        }
                        .onSubmit {
                            commitQuantity()
                        }
                        .onChange(of: isQuantityFocused) { _, isFocused in
                            if !isFocused {
                                commitQuantity()
                            }
                        }
                    
                    Button {
                        let newValue = state.quantity + 1
                        onQuantityChange(newValue)
                        quantityText = formatQuantity(newValue)
                        Haptics.light()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColor.textTitle)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpace.s12)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
        )
    }
    
    // MARK: - Serving Size Section (legacy - will be removed)
    
    private var servingSizeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Serving Size")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.textTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: AppSpace.sm) {
                // Default serving chip
                servingChip(
                    label: food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)",
                    isSelected: state.selectedServing == nil && !isCustomServingSelected,
                    action: onDefaultServingTap
                )
                
                // Display serving options (max 3)
                ForEach(displayServingOptions) { option in
                    servingChip(
                        label: option.label,
                        isSelected: state.selectedServing?.id == option.id && !isCustomServingSelected,
                        action: { onServingSizeTap(option) }
                    )
                }
                
                // Custom chip (always last, stable position) - only show if domain is understood
                if shouldShowCustomServing {
                    customServingChip
                }
            }
        }
    }
    
    private func servingChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            Haptics.light()
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, AppSpace.s12)
                .padding(.vertical, 8)
                .frame(height: 32)
                .background(isSelected ? AppColor.brandPrimary : AppColor.bgCard)
                .foregroundStyle(isSelected ? .white : AppColor.textTitle)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : AppColor.borderSubtle,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private var customServingChip: some View {
        Group {
            if isCustomAmountActive {
                HStack(spacing: 4) {
                    // TextField for numeric input only (no unit label inside)
                    TextField("", text: $customAmountText)
                        .keyboardType(.decimalPad)
                        .focused($isCustomAmountFocused)
                        .font(.subheadline)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .frame(height: 32)
                        .background(AppColor.bgCard)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppColor.brandPrimary, lineWidth: 2)
                        )
                        .onChange(of: customAmountText) { _, newValue in
                            if newValue.isEmpty {
                                // Clear custom immediately when field is empty
                                onCustomServingCommit(0)
                            } else if let domainAmount = parseAndSnapCustomAmount(newValue) {
                                // Convert domain units to grams before committing
                                let grams = domainUnitsToGrams(domainAmount)
                                onCustomServingCommit(grams)
                            }
                            // If invalid (like "d"), do nothing - leave last valid grams until commit
                        }
                        .onSubmit {
                            commitCustomAmount()
                        }
                    
                    Button {
                        commitCustomAmount()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColor.brandPrimary)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                }
            } else {
                Button {
                    isCustomAmountActive = true
                    // Always start with an empty field when entering Custom
                    customAmountText = ""
                    isCustomAmountFocused = true
                    // Do not commit anything yet; wait for user input
                    Haptics.light()
                } label: {
                    // Show custom amount if set, otherwise "Custom"
                    Group {
                        if let customAmount = state.customAmountInGrams, customAmount > 0 {
                            Text(formatCustomAmountLabel(grams: customAmount))
                        } else {
                            Text("Custom")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, AppSpace.s12)
                    .padding(.vertical, 8)
                    .frame(height: 32)
                    .background(
                        isCustomServingSelected
                        ? AppColor.brandPrimary
                        : AppColor.bgCard
                    )
                    .foregroundStyle(
                        isCustomServingSelected
                        ? .white
                        : AppColor.textTitle
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                isCustomServingSelected
                                ? Color.clear
                                : AppColor.borderSubtle,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func commitCustomAmount() {
        guard let domainAmount = parseAndSnapCustomAmount(customAmountText) else {
            // Invalid or too small value - clear custom
            onCustomServingCommit(0)
            isCustomAmountActive = false
            customAmountText = ""
            isCustomAmountFocused = false
            return
        }
        
        // Convert domain units to grams before committing
        let grams = domainUnitsToGrams(domainAmount)
        onCustomServingCommit(grams)
        isCustomAmountActive = false
        isCustomAmountFocused = false
    }
    
    // MARK: - Quantity Section
    
    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Quantity")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.textTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button {
                    let newValue = max(0.1, state.quantity - 1)
                    onQuantityChange(newValue)
                    quantityText = formatQuantity(newValue)
                    Haptics.light()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColor.textTitle.opacity(state.quantity > 1 ? 1 : 0.4))
                }
                .buttonStyle(.plain)
                .disabled(state.quantity <= 1)
                
                TextField("", text: $quantityText)
                    .keyboardType(.decimalPad)
                    .focused($isQuantityFocused)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
                    .frame(width: 70)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                    )
                    .onChange(of: quantityText) { _, newValue in
                        if newValue.isEmpty {
                            return
                        }
                        if let value = Double(newValue) {
                            let rounded = (value * 100).rounded() / 100
                            if rounded > 0 {
                                onQuantityChange(rounded)
                            }
                        }
                    }
                    .onSubmit {
                        commitQuantity()
                    }
                    .onChange(of: isQuantityFocused) { _, isFocused in
                        if !isFocused {
                            commitQuantity()
                        }
                    }
                
                Button {
                    let newValue = state.quantity + 1
                    onQuantityChange(newValue)
                    quantityText = formatQuantity(newValue)
                    Haptics.light()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColor.textTitle)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func commitQuantity() {
        if quantityText.isEmpty {
            quantityText = formatQuantity(state.quantity)
        } else if let value = Double(quantityText) {
            let rounded = (value * 100).rounded() / 100
            let finalValue = max(0.1, rounded)
            onQuantityChange(finalValue)
            quantityText = formatQuantity(finalValue)
        } else {
            quantityText = formatQuantity(state.quantity)
        }
    }
    
    // MARK: - Nutrition Section
    
    private var nutritionSection: some View {
        VStack(spacing: AppSpace.s12) {
            // Calories (total, not per serving)
            VStack(spacing: 4) {
                Text("\(scaledCalories)")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)
                
                Text("kcal")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textMuted)
            }
            .padding(.top, AppSpace.s12)
            
            // Donut chart and macros
            HStack(spacing: AppSpace.s24) {
                // Donut chart
                donutChart
                    .frame(width: 72, height: 72)
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                
                // Macros
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    macroRow(label: "Protein", value: formatMacro(scaledProtein), color: AppColor.macroProtein)
                    macroRow(label: "Carbs", value: formatMacro(scaledCarbs), color: AppColor.macroCarbs)
                    macroRow(label: "Fat", value: formatMacro(scaledFat), color: AppColor.macroFat)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpace.s12)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
        )
    }
    
    private var donutChart: some View {
        ZStack {
            Circle()
                .stroke(AppColor.borderSubtle.opacity(0.2), lineWidth: 10)
            
            if totalMacros > 0 {
                let proteinAngle = (scaledProtein / totalMacros) * 360
                let carbsAngle = (scaledCarbs / totalMacros) * 360
                let fatAngle = (scaledFat / totalMacros) * 360
                
                Group {
                    DonutSegment(
                        startAngle: 0,
                        endAngle: proteinAngle,
                        color: AppColor.macroProtein
                    )
                    
                    DonutSegment(
                        startAngle: proteinAngle,
                        endAngle: proteinAngle + carbsAngle,
                        color: AppColor.macroCarbs
                    )
                    
                    DonutSegment(
                        startAngle: proteinAngle + carbsAngle,
                        endAngle: proteinAngle + carbsAngle + fatAngle,
                        color: AppColor.macroFat
                    )
                }
                .animation(shouldAnimateDonut ? .spring(response: 0.6, dampingFraction: 0.7) : nil, value: totalMacros)
            }
        }
    }
    
    private func macroRow(label: String, value: String, color: Color) -> some View {
        HStack(spacing: AppSpace.sm) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.footnote)
                .foregroundStyle(AppColor.textMuted)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
    }
    
    // MARK: - Full Nutrition Section
    
    private var fullNutritionSection: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            Button {
                withAnimation {
                    showFullNutrition.toggle()
                }
                Haptics.light()
            } label: {
                HStack {
                    Text("View Full Nutrition")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.textTitle)
                    
                    Spacer()
                    
                    Image(systemName: showFullNutrition ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .systemGray6))
                )
            }
            .buttonStyle(.plain)
            
            if showFullNutrition {
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    nutritionRow(label: "Fiber", value: "0g")
                    nutritionRow(label: "Sugar", value: "0g")
                    nutritionRow(label: "Sodium", value: "0mg")
                    nutritionRow(label: "Cholesterol", value: "0mg")
                    nutritionRow(label: "Potassium", value: "0mg")
                }
                .padding(.top, AppSpace.sm)
            }
        }
    }
    
    private func nutritionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppColor.textMuted)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppColor.textTitle)
        }
    }
    
    // MARK: - Schedule Card
    
    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: AppSpace.s12) {
            // Header: Clock icon + "Schedule" on left, Recurring pill on right
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textTitle)
                    Text("Schedule")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.textTitle)
                }
                
                Spacer()
                
                Button {
                    onRecurringToggle()
                    Haptics.light()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline)
                        Text("Recurring")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(state.isRecurring ? AppColor.brandPrimary : Color(uiColor: .systemGray6))
                    )
                    .foregroundStyle(state.isRecurring ? .white : AppColor.textTitle)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weekday chips (derived from dateSequence)
            HStack(spacing: 4) {
                ForEach(dateSequence, id: \.self) { date in
                    weekdayChip(date: date)
                }
            }
            
            // Date chips (same sequence)
            HStack(spacing: 4) {
                ForEach(dateSequence, id: \.self) { date in
                    dateChip(date: date)
                }
            }
            
            // Recurring end date row
            if state.isRecurring {
                Button {
                    showEndDatePicker = true
                } label: {
                    HStack {
                        Text("Until")
                            .font(.caption)
                            .foregroundStyle(AppColor.textMuted)
                        
                        Text(endDateString)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColor.textTitle)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppColor.textMuted)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(uiColor: .systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, AppSpace.s12)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
        )
    }
    
    private func weekdayChip(date: Date) -> some View {
        let calendar = Calendar.current
        let weekday = Weekday.from(date)
        let isSelected = state.selectedWeekdays.contains(weekday)
        let isTodayWeekday = calendar.isDateInToday(date)
        
        return Button {
            onWeekdayToggle(weekday)
            Haptics.light()
        } label: {
            // Use formatter to ensure alignment with date sequence
            Text(weekdayFormatter.string(from: date))
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(width: 36, height: 24)
                .minimumScaleFactor(0.8)
                .background(
                    state.isRecurring
                    ? (isSelected ? AppColor.brandPrimary : Color(uiColor: .systemGray6))
                    : (isTodayWeekday ? Color(uiColor: .systemGray6).opacity(0.6) : Color(uiColor: .systemGray6))
                )
                .foregroundStyle(
                    state.isRecurring
                    ? (isSelected ? .white : AppColor.textTitle)
                    : AppColor.textMuted
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private func dateChip(date: Date) -> some View {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let baseDate = calendar.startOfDay(for: state.baseDate)
        let isSelected = state.selectedDates.contains(normalizedDate)
        let isToday = calendar.isDate(normalizedDate, inSameDayAs: baseDate)
        
        return Button {
            onDateToggle(date)
            Haptics.light()
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 36, height: 32)
                .background(
                    Circle()
                        .fill(
                            isSelected
                            ? AppColor.brandPrimary
                            : Color.clear
                        )
                )
                .foregroundStyle(
                    isSelected
                    ? .white
                    : AppColor.textTitle
                )
                .overlay(
                    Circle()
                        .stroke(
                            // Show blue outline only when today is the default (no selections) and not selected
                            isToday && !isSelected && !state.isRecurring && state.selectedDates.isEmpty
                            ? AppColor.brandPrimary
                            : (isSelected ? Color.clear : Color(uiColor: .systemGray4)),
                            lineWidth: isSelected ? 0 : 1
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(state.isRecurring)
        .opacity(state.isRecurring ? 0.3 : 1)
        .allowsHitTesting(!state.isRecurring)
    }
    
    private var endDatePickerSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpace.s16) {
                DatePicker(
                    "Until",
                    selection: Binding(
                        get: { state.recurringEndDate ?? Date() },
                        set: { onRecurringEndDateChange($0) }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Recurring End Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showEndDatePicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showEndDatePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActions: some View {
        Button {
            onAdd(meal)
            Haptics.success()
        } label: {
            Text("Add to \(meal.displayName)")
                .font(AppFont.label(16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpace.s16)
                .background(
                    isAddButtonEnabled
                    ? AppColor.brandPrimary
                    : AppColor.brandPrimary.opacity(0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
        .disabled(!isAddButtonEnabled)
        .padding(.horizontal, AppSpace.s16)
        .padding(.bottom, AppSpace.s16)
        .background(AppColor.bgScreen)
    }
    
    // MARK: - Helpers
    
    private func formatMacro(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))g"
        }
        return String(format: "%.1fg", value)
    }
    
    private func formatQuantity(_ value: Double) -> String {
        let rounded = (value * 100).rounded() / 100
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(rounded))
        }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: rounded)) ?? String(format: "%.2f", rounded)
    }
}

// MARK: - Donut Chart Segment

struct DonutSegment: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    
    var body: some View {
        Circle()
            .trim(from: startAngle / 360, to: endAngle / 360)
            .stroke(color, style: StrokeStyle(lineWidth: 7, lineCap: .round))
            .rotationEffect(.degrees(-90))
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var detailState = AddFoodViewModel.FoodDetailState(
            selectedServing: nil,
            customAmountInGrams: nil,
            quantity: 1.0,
            selectedWeekdays: [.monday],
            selectedDates: [Date()],
            isRecurring: false,
            recurringEndDate: nil,
            baseDate: Calendar.current.startOfDay(for: Date())
        )
        
        let sampleFood = FoodDefinition(
            id: UUID(),
            name: "Chicken breast, cooked",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: [
                FoodDefinition.ServingOption(id: UUID(), label: "100g", amountInGrams: 100),
                FoodDefinition.ServingOption(id: UUID(), label: "150g", amountInGrams: 150),
                FoodDefinition.ServingOption(id: UUID(), label: "200g", amountInGrams: 200)
            ],
            macros: FoodDefinition.Macros(calories: 165, protein: 31, carbs: 0, fat: 3.6),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        
        var body: some View {
            FoodDetailSheet(
                food: sampleFood,
                state: $detailState,
                meal: .breakfast,
                isFavorite: false,
                onServingSizeTap: { _ in },
                onDefaultServingTap: { },
                onCustomServingCommit: { _ in },
                onQuantityChange: { _ in },
                onWeekdayToggle: { _ in },
                onDateToggle: { _ in },
                onRecurringToggle: { },
                onAdd: { _ in },
                onCancel: { },
                onFavoriteToggle: { },
                onRecurringEndDateChange: { _ in }
            )
        }
    }
    
    return PreviewWrapper()
}
