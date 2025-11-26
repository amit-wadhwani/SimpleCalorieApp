import Foundation

enum Weekday: Int, CaseIterable, Hashable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var displayName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    static func from(_ date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return Weekday(rawValue: weekday) ?? .monday
    }
}

@MainActor
final class AddFoodViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var rows: [FoodRowProps] = []
    @Published var results: [FoodDefinition] = []
    @Published var selectedFood: FoodDefinition?
    @Published var isShowingDetail: Bool = false
    @Published var foodDetailState: FoodDetailState?
    
    private let searchService: FoodSearchService
    var onFoodAdded: ((FoodItem, MealType) -> Void)?
    var onFoodAddedToDates: (([Date], FoodItem, MealType) -> Void)?
    var selectedDate: Date = Date() // Can be injected from TodayViewModel

    struct FoodDetailState {
        var selectedServing: FoodDefinition.ServingOption?  // nil => use base serving
        var customAmountInGrams: Double?                    // nil => use selectedServing.amountInGrams
        var quantity: Double                                // 1.0 by default
        var selectedWeekdays: Set<Weekday>                  // e.g. [.thursday]
        var selectedDates: Set<Date>                        // explicit calendar dates
        var isRecurring: Bool                               // true => use weekdays
        var recurringEndDate: Date?                         // end date for recurring pattern
        var baseDate: Date                                  // anchor date for schedule UI (doesn't change when toggling recurring)
    }

    init(searchService: FoodSearchService) {
        self.searchService = searchService
        Task { await refresh() }
    }

    func refresh() async {
        do {
            results = try await searchService.searchFoods(matching: query)
            rows = results.map { food in
                let servingDescription = food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)"
                return FoodRowProps(
                    id: food.id,
                    name: food.name,
                    serving: servingDescription,
                    protein: "\(trim(food.macros.protein))g",
                    carbs: "\(trim(food.macros.carbs))g",
                    fat: "\(trim(food.macros.fat))g",
                    kcal: "\(food.macros.calories)"
                )
            }
        } catch {
            results = []
            rows = []
        }
    }

    private func trim(_ v: Double) -> String {
        if v.rounded() == v { return String(Int(v)) }
        return String(format: "%.1f", v)
    }

    // MARK: - Selection & Detail Sheet

    // Generate smart serving presets with fractional options
    func generateDisplayServingOptions(for food: FoodDefinition) -> [FoodDefinition.ServingOption] {
        let maxLabelLength = 12 // Max characters to avoid truncation
        var candidates: [FoodDefinition.ServingOption] = []
        
        // Base serving (always include if it fits)
        let baseLabel = food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)"
        if baseLabel.count <= maxLabelLength {
            candidates.append(FoodDefinition.ServingOption(
                id: UUID(),
                label: baseLabel,
                amountInGrams: food.serving.amount
            ))
        }
        
        // Generate fractional/multiple presets based on serving type
        let unit = food.serving.unit.lowercased()
        let baseAmount = food.serving.amount
        
        // For volume-based (cup, tbsp, ml, etc.) or unit-based (slice, piece, etc.)
        if unit.contains("cup") || unit.contains("tbsp") || unit.contains("tsp") || 
           unit.contains("ml") || unit.contains("slice") || unit.contains("piece") ||
           unit.contains("item") {
            // Generate 0.5x, 1.5x, 2x variants
            let multipliers: [Double] = [0.5, 1.5, 2.0]
            for multiplier in multipliers {
                let amount = baseAmount * multiplier
                let label = formatServingLabel(amount: amount, unit: food.serving.unit, multiplier: multiplier)
                if label.count <= maxLabelLength && !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: amount
                    ))
                }
            }
        } else if unit == "g" || unit == "gram" || unit == "grams" {
            // For gram-based, generate 50g, 100g, 150g, 200g variants
            let gramAmounts: [Double] = [50, 100, 150, 200]
            for gramAmount in gramAmounts {
                let label = "\(Int(gramAmount))g"
                if label.count <= maxLabelLength && !candidates.contains(where: { $0.label == label }) {
                    candidates.append(FoodDefinition.ServingOption(
                        id: UUID(),
                        label: label,
                        amountInGrams: gramAmount
                    ))
                }
            }
        }
        
        // Add any existing servingOptions that fit
        if let existingOptions = food.servingOptions {
            for option in existingOptions {
                if option.label.count <= maxLabelLength && 
                   !candidates.contains(where: { $0.label == option.label }) {
                    candidates.append(option)
                }
            }
        }
        
        // Sort by amount in grams (increasing order)
        candidates.sort { $0.amountInGrams < $1.amountInGrams }
        
        // Limit to 3 presets (excluding base if it's already included)
        var result: [FoodDefinition.ServingOption] = []
        var seenBase = false
        
        for candidate in candidates {
            if result.count >= 3 {
                break
            }
            // Always include base serving if it exists
            if candidate.label == baseLabel && !seenBase {
                result.append(candidate)
                seenBase = true
            } else if candidate.label != baseLabel {
                result.append(candidate)
            }
        }
        
        // If base wasn't added and we have space, add it
        if !seenBase && result.count < 3 {
            if let base = candidates.first(where: { $0.label == baseLabel }) {
                result.insert(base, at: 0)
            }
        }
        
        return result
    }
    
    private func formatServingLabel(amount: Double, unit: String, multiplier: Double) -> String {
        if multiplier == 0.5 {
            return "½ \(unit)"
        } else if multiplier == 1.5 {
            return "1½ \(unit)s"
        } else if multiplier == 2.0 {
            let intAmount = Int(amount)
            return "\(intAmount) \(unit)s"
        } else {
            let intAmount = Int(amount)
            return "\(intAmount)\(unit)"
        }
    }

    func didSelectFood(_ food: FoodDefinition) {
        selectedFood = food
        isShowingDetail = true

        // Compute today (normalized to start of day)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: selectedDate)
        let todayWeekday = Weekday.from(today)

        // Initialize recurring end date (default: today + 3 months)
        let defaultEndDate = calendar.date(byAdding: .month, value: 3, to: today) ?? today
        
        // Initialize FoodDetailState
        // selectedServing = nil means "use base serving by default"
        // baseDate anchors the schedule UI and doesn't change when toggling recurring
        foodDetailState = FoodDetailState(
            selectedServing: nil,
            customAmountInGrams: nil,
            quantity: 1.0,
            selectedWeekdays: [todayWeekday],
            selectedDates: [today],
            isRecurring: false,
            recurringEndDate: defaultEndDate,
            baseDate: today
        )
    }

    func quickAddFood(_ food: FoodDefinition, to meal: MealType) {
        // Quick add: base serving, quantity = 1, today only
        let baseGrams = food.serving.amount // Assuming serving.amount is in grams
        let scaledMacros = scaleMacros(food.macros, by: 1.0)
        let servingDescription = food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)"
        
        let foodItem = FoodItem(
            name: food.name,
            calories: scaledMacros.calories,
            description: servingDescription,
            protein: scaledMacros.protein,
            carbs: scaledMacros.carbs,
            fat: scaledMacros.fat
        )
        
        onFoodAdded?(foodItem, meal)
    }

    // MARK: - Serving and Quantity Adjustments

    func selectServingOption(_ option: FoodDefinition.ServingOption) {
        guard var state = foodDetailState else { return }
        state.selectedServing = option
        state.customAmountInGrams = nil // Clear custom amount when selecting a preset
        foodDetailState = state
    }

    func selectDefaultServing() {
        guard var state = foodDetailState else { return }
        state.selectedServing = nil
        state.customAmountInGrams = nil
        foodDetailState = state
    }

    func setCustomAmount(_ amountInGrams: Double?) {
        guard var state = foodDetailState else { return }
        if let amount = amountInGrams, amount > 0 {
            state.customAmountInGrams = amount
        } else {
            // If nil or invalid, clear custom and revert to default serving
            state.customAmountInGrams = nil
            // Keep selectedServing as is (for reference), but visually it will be unselected
        }
        foodDetailState = state
    }

    func incrementQuantity() {
        guard var state = foodDetailState else { return }
        state.quantity += 1
        foodDetailState = state
    }

    func decrementQuantity() {
        guard var state = foodDetailState else { return }
        state.quantity = max(1, state.quantity - 1)
        foodDetailState = state
    }

    func setQuantity(_ quantity: Double) {
        guard var state = foodDetailState else { return }
        state.quantity = max(0.1, quantity)
        foodDetailState = state
    }

    // MARK: - Multi-day & Recurring

    func toggleWeekday(_ weekday: Weekday) {
        guard var state = foodDetailState else { return }
        let calendar = Calendar.current
        
        // Use state.baseDate as the anchor
        let baseDate = calendar.startOfDay(for: state.baseDate)
        
        if !state.isRecurring {
            // Day mode: switch to recurring mode with tapped weekday
            state.isRecurring = true
            state.selectedDates.removeAll()
            state.selectedWeekdays = [weekday]
            // Ensure end date is set (3 months from baseDate)
            if state.recurringEndDate == nil {
                state.recurringEndDate = calendar.date(byAdding: .month, value: 3, to: baseDate) ?? baseDate
            }
        } else {
            // Recurring mode: toggle weekday
            if state.selectedWeekdays.contains(weekday) {
                state.selectedWeekdays.remove(weekday)
            } else {
                state.selectedWeekdays.insert(weekday)
            }
        }
        // baseDate remains unchanged
        foodDetailState = state
    }

    func toggleDate(_ date: Date) {
        guard var state = foodDetailState else { return }
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let baseDate = calendar.startOfDay(for: state.baseDate)
        
        if state.isRecurring {
            // Recurring mode: switch to day mode with tapped date
            state.isRecurring = false
            state.selectedDates = [normalizedDate]
        } else {
            // Day mode: toggle date (allow multi-select)
            if state.selectedDates.contains(normalizedDate) {
                state.selectedDates.remove(normalizedDate)
                // If removing this date would leave selectedDates empty, reset to baseDate
                if state.selectedDates.isEmpty {
                    state.selectedDates = [baseDate]
                }
            } else {
                state.selectedDates.insert(normalizedDate)
            }
        }
        foodDetailState = state
    }

    func toggleRecurring() {
        guard var state = foodDetailState else { return }
        let calendar = Calendar.current
        
        // Use state.baseDate as the anchor (never change it when toggling)
        let baseDate = calendar.startOfDay(for: state.baseDate)
        let baseWeekday = Weekday.from(baseDate)
        
        if state.isRecurring {
            // Toggling OFF: switch to day mode
            state.isRecurring = false
            
            if !state.selectedWeekdays.isEmpty {
                // Map selectedWeekdays to dates in dateSequence (next 7 days from baseDate)
                var mappedDates: Set<Date> = []
                for offset in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: offset, to: baseDate) {
                        let weekday = Weekday.from(date)
                        if state.selectedWeekdays.contains(weekday) {
                            mappedDates.insert(calendar.startOfDay(for: date))
                        }
                    }
                }
                state.selectedDates = mappedDates.isEmpty ? [baseDate] : mappedDates
            } else {
                // No weekdays selected, use baseDate
                state.selectedDates = [baseDate]
            }
        } else {
            // Toggling ON: switch to recurring mode
            state.isRecurring = true
            
            if !state.selectedDates.isEmpty {
                // Convert selectedDates to selectedWeekdays
                state.selectedWeekdays = Set(state.selectedDates.map { Weekday.from($0) })
            } else {
                // No dates selected, use baseDate's weekday
                state.selectedWeekdays = [baseWeekday]
            }
            
            // Clear selectedDates (we're in recurring mode now)
            state.selectedDates.removeAll()
            
            // Ensure end date is set (3 months from baseDate)
            if state.recurringEndDate == nil {
                state.recurringEndDate = calendar.date(byAdding: .month, value: 3, to: baseDate) ?? baseDate
            }
        }
        // baseDate remains unchanged
        foodDetailState = state
    }
    
    func updateRecurringEndDate(_ date: Date) {
        guard var state = foodDetailState else { return }
        state.recurringEndDate = date
        foodDetailState = state
    }

    // MARK: - Confirm Add

    func confirmAddFromDetail(to meal: MealType) {
        guard let food = selectedFood,
              let state = foodDetailState else { return }

        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: selectedDate)

        // 1. Determine target dates
        let targetDates: [Date]
        if state.isRecurring {
            // Generate all matching dates from baseDate to recurringEndDate
            let endDate = state.recurringEndDate ?? baseDate
            let allDates = allDates(from: baseDate, to: endDate)
            targetDates = allDates.filter { date in
                let weekday = Weekday.from(date)
                return state.selectedWeekdays.contains(weekday)
            }
        } else {
            targetDates = state.selectedDates.isEmpty ? [baseDate] : Array(state.selectedDates)
        }

        // 2. For each target date, compute macros & calories and add entry
        for date in targetDates {
            addEntry(food: food, detailState: state, on: date, meal: meal)
        }

        // 3. Reset UI
        isShowingDetail = false
        selectedFood = nil
        foodDetailState = nil
    }

    // MARK: - Helper Methods

    private func addEntry(food: FoodDefinition, detailState: FoodDetailState, on date: Date, meal: MealType) {
        // Determine serving grams
        let baseGrams: Double
        if let option = detailState.selectedServing {
            baseGrams = option.amountInGrams
        } else {
            // Use base serving amount (assuming it's in grams)
            baseGrams = food.serving.amount
        }

        let grams = detailState.customAmountInGrams ?? baseGrams
        let quantity = detailState.quantity

        // Calculate factor: (grams / baseGrams) * quantity
        let factor = (grams / baseGrams) * quantity

        // Scale macros & calories
        let scaledMacros = scaleMacros(food.macros, by: factor)

        // Create serving description
        let servingDescription: String
        if let custom = detailState.customAmountInGrams {
            servingDescription = "\(Int(custom))g"
        } else if let option = detailState.selectedServing {
            servingDescription = option.label
        } else {
            servingDescription = food.serving.description ?? "\(Int(food.serving.amount))\(food.serving.unit)"
        }

        let foodItem = FoodItem(
            name: food.name,
            calories: scaledMacros.calories,
            description: servingDescription,
            protein: scaledMacros.protein,
            carbs: scaledMacros.carbs,
            fat: scaledMacros.fat
        )

        // Use multi-date callback if available, otherwise single-date
        if let multiDateCallback = onFoodAddedToDates {
            multiDateCallback([date], foodItem, meal)
        } else {
            onFoodAdded?(foodItem, meal)
        }
    }

    private func allDates(from startDate: Date, to endDate: Date) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        var currentDate = startDate
        
        // Ensure endDate >= startDate
        let finalEndDate = endDate >= startDate ? endDate : startDate
        
        while currentDate <= finalEndDate {
            dates.append(calendar.startOfDay(for: currentDate))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }

    private func scaleMacros(_ macros: FoodDefinition.Macros, by factor: Double) -> (calories: Int, protein: Double, carbs: Double, fat: Double) {
        return (
            calories: Int((Double(macros.calories) * factor).rounded()),
            protein: macros.protein * factor,
            carbs: macros.carbs * factor,
            fat: macros.fat * factor
        )
    }
}
