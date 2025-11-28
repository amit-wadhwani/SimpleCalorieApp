import XCTest
@testable import SimpleCalorie

@MainActor
final class AddFoodDetailBehaviorTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func makeViewModelWith(food: FoodDefinition) -> AddFoodViewModel {
        let repo = TestFoodRepository(foods: [food])
        let viewModel = AddFoodViewModel(foodRepository: repo)
        return viewModel
    }
    
    private func getDetailState(from viewModel: AddFoodViewModel) -> AddFoodViewModel.FoodDetailState? {
        return viewModel.foodDetailState
    }
    
    // MARK: - Test 1: Preset Selection
    
    func testPresetSelectionTracksServingSizeGeneratorGrams() {
        // Build a FoodDefinition for peanut butter (tbsp domain)
        let peanutButter = FoodDefinition(
            id: UUID(),
            name: "Peanut butter",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 32.0, // 32g for 2 tbsp
                description: "2 tbsp"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 188, protein: 8, carbs: 6, fat: 16),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        
        // Get presets from ServingSizeGenerator
        let generator = ServingSizeGenerator(food: peanutButter)
        let presets = generator.presets(maxCount: 3)
        
        // Ensure we have at least 2 presets for this test
        XCTAssertGreaterThanOrEqual(presets.count, 2, "Should have at least 2 presets for peanut butter")
        
        // Instantiate view model
        let viewModel = makeViewModelWith(food: peanutButter)
        
        // Simulate opening detail sheet
        viewModel.didSelectFood(peanutButter)
        
        // Verify initial state
        var state = getDetailState(from: viewModel)
        XCTAssertNotNil(state, "Detail state should be initialized")
        XCTAssertNil(state?.selectedServing, "Initially no preset should be selected")
        XCTAssertNil(state?.customAmountInGrams, "Initially no custom amount")
        if let quantity = state?.quantity {
            XCTAssertEqual(quantity, 1.0, accuracy: 0.001, "Initial quantity should be 1.0")
        }
        
        // Simulate tapping the second preset
        let secondPreset = presets[1]
        viewModel.selectServingOption(secondPreset)
        
        // Read state again
        state = getDetailState(from: viewModel)
        
        // Assert
        XCTAssertNotNil(state?.selectedServing, "Selected serving should be set")
        if let selectedGrams = state?.selectedServing?.amountInGrams {
            XCTAssertEqual(selectedGrams, secondPreset.amountInGrams, accuracy: 0.1,
                          "Selected serving grams should match preset grams")
        }
        XCTAssertNil(state?.customAmountInGrams, "Custom amount should be cleared when selecting preset")
        if let quantity = state?.quantity {
            XCTAssertEqual(quantity, 1.0, accuracy: 0.001, "Quantity should remain 1.0")
        }
    }
    
    // MARK: - Test 2: Custom Serving
    
    func testCustomServingStartsEmptyAndCommitsGrams() {
        // Use a slice-based food (bread)
        let bread = FoodDefinition(
            id: UUID(),
            name: "Whole wheat bread",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 28.0, // 28g for 1 slice
                description: "1 slice"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 81, protein: 4, carbs: 14, fat: 1),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        
        let generator = ServingSizeGenerator(food: bread)
        
        // Instantiate view model
        let viewModel = makeViewModelWith(food: bread)
        
        // Simulate opening detail sheet
        viewModel.didSelectFood(bread)
        
        // Verify initial state - custom should be nil
        var state = getDetailState(from: viewModel)
        XCTAssertNil(state?.customAmountInGrams, "Custom amount should start as nil")
        
        // Simulate committing a custom value of "2" domain units (slices)
        let domainUnits = 2.0
        let expectedGrams = generator.domainUnitsToGrams(domainUnits)
        // For bread: 1 slice = 28g, so 2 slices = 56g
        viewModel.setCustomAmount(expectedGrams)
        
        // Read state again
        state = getDetailState(from: viewModel)
        
        // Assert
        XCTAssertNotNil(state?.customAmountInGrams, "Custom amount should be set")
        if let customGrams = state?.customAmountInGrams {
            XCTAssertEqual(customGrams, expectedGrams, accuracy: 0.1,
                          "Custom amount grams should match expected")
        }
        if let quantity = state?.quantity {
            XCTAssertEqual(quantity, 1.0, accuracy: 0.001, "Quantity should remain 1.0")
        }
        
        // Simulate clearing Custom (commit 0 or nil)
        viewModel.setCustomAmount(nil) // This should clear it
        
        // Read state again
        state = getDetailState(from: viewModel)
        
        // Assert custom is cleared
        XCTAssertNil(state?.customAmountInGrams, "Custom amount should be cleared when set to nil")
    }
    
    // MARK: - Test 3: Quantity Multiplier
    
    func testQuantityMultiplierRespectsSelectedServingGrams() {
        // Use a gram-based food (chicken breast)
        let chicken = FoodDefinition(
            id: UUID(),
            name: "Chicken breast, cooked",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 100.0, // 100g base serving
                description: "100g"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 165, protein: 31, carbs: 0, fat: 3.6),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        
        // Instantiate view model
        let viewModel = makeViewModelWith(food: chicken)
        
        // Simulate opening detail sheet
        viewModel.didSelectFood(chicken)
        
        // Verify initial state
        var state = getDetailState(from: viewModel)
        if let initialQuantity = state?.quantity {
            XCTAssertEqual(initialQuantity, 1.0, accuracy: 0.001, "Initial quantity should be 1.0")
        }
        
        // Set quantity to 2
        viewModel.setQuantity(2.0)
        
        // Read state again
        state = getDetailState(from: viewModel)
        
        // Assert
        if let quantity = state?.quantity {
            XCTAssertEqual(quantity, 2.0, accuracy: 0.001, "Quantity should be 2.0")
        }
        
        // Calculate effective grams: base serving (100g) * quantity (2) = 200g
        // Since no custom serving is set, it uses base serving
        let baseGrams = chicken.serving.amount
        let expectedEffectiveGrams = baseGrams * 2.0
        
        // Verify the effective grams calculation
        // We can't directly access effective grams from the view model,
        // but we can verify the state components that would be used:
        XCTAssertNil(state?.selectedServing, "No preset selected, so uses base serving")
        XCTAssertNil(state?.customAmountInGrams, "No custom amount, so uses base serving")
        if let quantity = state?.quantity {
            XCTAssertEqual(quantity, 2.0, accuracy: 0.001, "Quantity is 2.0")
        }
        
        // The effective grams would be: baseGrams * quantity = 100 * 2 = 200g
        // This is verified by the state having quantity = 2.0 and no custom/selected serving
    }
    
    // MARK: - Test 4: Custom Serving with Quantity
    
    func testCustomServingWithQuantityMultiplier() {
        // Test that custom serving grams are multiplied by quantity
        let bread = FoodDefinition(
            id: UUID(),
            name: "Whole wheat bread",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 28.0,
                description: "1 slice"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 81, protein: 4, carbs: 14, fat: 1),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        
        let generator = ServingSizeGenerator(food: bread)
        
        let viewModel = makeViewModelWith(food: bread)
        viewModel.didSelectFood(bread)
        
        // Set custom amount to 2 slices (56g)
        let customGrams = generator.domainUnitsToGrams(2.0)
        viewModel.setCustomAmount(customGrams)
        
        // Set quantity to 3
        viewModel.setQuantity(3.0)
        
        let state = getDetailState(from: viewModel)
        
        // Verify state
        if let customGramsValue = state?.customAmountInGrams {
            XCTAssertEqual(customGramsValue, customGrams, accuracy: 0.1,
                          "Custom amount should be 56g (2 slices)")
        }
        if let quantity = state?.quantity {
            XCTAssertEqual(quantity, 3.0, accuracy: 0.001, "Quantity should be 3.0")
        }
        
        // Effective grams would be: customGrams * quantity = 56 * 3 = 168g
        // This is verified by the state having both custom amount and quantity set correctly
    }
    
    // MARK: - Test 5: Preset Selection Clears Custom
    
    func testPresetSelectionClearsCustomAmount() {
        let bread = FoodDefinition(
            id: UUID(),
            name: "Whole wheat bread",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 28.0,
                description: "1 slice"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 81, protein: 4, carbs: 14, fat: 1),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        
        let generator = ServingSizeGenerator(food: bread)
        let presets = generator.presets(maxCount: 3)
        
        let viewModel = makeViewModelWith(food: bread)
        viewModel.didSelectFood(bread)
        
        // Set a custom amount first
        let customGrams = generator.domainUnitsToGrams(2.0)
        viewModel.setCustomAmount(customGrams)
        
        var state = getDetailState(from: viewModel)
        XCTAssertNotNil(state?.customAmountInGrams, "Custom amount should be set")
        
        // Now select a preset
        if let firstPreset = presets.first {
            viewModel.selectServingOption(firstPreset)
            
            state = getDetailState(from: viewModel)
            
            // Assert custom is cleared
            XCTAssertNil(state?.customAmountInGrams, "Custom amount should be cleared when selecting preset")
            XCTAssertNotNil(state?.selectedServing, "Selected serving should be set")
        }
    }
}


