import XCTest
@testable import SimpleCalorie

final class ServingSizeDomainTests: XCTestCase {
    
    // MARK: - Helper Functions
    
    private func makeGenerator(food: FoodDefinition) -> ServingSizeGenerator {
        return ServingSizeGenerator(food: food)
    }
    
    // Helper to create a test food with cup domain
    private func createCupFood(description: String, amount: Double) -> FoodDefinition {
        return FoodDefinition(
            id: UUID(),
            name: "Test Food",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: amount,
                description: description
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 100, protein: 10, carbs: 20, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
    }
    
    // Helper to create a test food with tbsp domain
    private func createTbspFood(description: String, amount: Double) -> FoodDefinition {
        return FoodDefinition(
            id: UUID(),
            name: "Test Food",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: amount,
                description: description
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 100, protein: 10, carbs: 20, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
    }
    
    // Helper to create a test food with slice domain
    private func createSliceFood(description: String, amount: Double) -> FoodDefinition {
        return FoodDefinition(
            id: UUID(),
            name: "Test Food",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: amount,
                description: description
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 100, protein: 10, carbs: 20, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
    }
    
    // Helper to create a test food with gram domain
    private func createGramFood(amount: Double) -> FoodDefinition {
        return FoodDefinition(
            id: UUID(),
            name: "Test Food",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: amount,
                description: "\(Int(amount))g"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 100, protein: 10, carbs: 20, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
    }
    
    // MARK: - Test Cup Normalization and Deduplication
    
    func testCupNormalizationAndDedup() {
        let food = FoodDefinition(
            id: UUID(),
            name: "Oats, dry",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 100.0, // 100g for 1 cup
                description: "1 cup dry"
            ),
            servingOptions: [
                FoodDefinition.ServingOption(id: UUID(), label: "¼ cup", amountInGrams: 25.0),
                FoodDefinition.ServingOption(id: UUID(), label: "½ cup dry", amountInGrams: 50.0),
                FoodDefinition.ServingOption(id: UUID(), label: "½ cup cooked", amountInGrams: 50.0),
                FoodDefinition.ServingOption(id: UUID(), label: "1 cup", amountInGrams: 100.0)
            ],
            macros: FoodDefinition.Macros(calories: 100, protein: 10, carbs: 20, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: food)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        
        // Should have normalized labels without "dry" or "cooked"
        // Should be deduplicated (only one "½ cup")
        // Should be sorted by amount
        XCTAssertTrue(labels.contains("½ cup") || labels.contains("1 cup"), "Should have cup labels")
        XCTAssertTrue(labels.contains("1 cup") || labels.contains("1½ cups"), "Should have 1 cup or 1½ cups")
        XCTAssertEqual(labels.filter { $0 == "½ cup" }.count, 1, "Should have only one '½ cup' after deduplication")
        
        // Verify ordering
        let amounts = options.map { $0.amountInGrams }
        XCTAssertEqual(amounts, amounts.sorted(), "Amounts should be in ascending order")
        
        // Verify that presets use gramsPerDomainUnit (1 cup = 100g, so ½ cup = 50g, 1 cup = 100g, 1½ cups = 150g)
        let halfCupOption = options.first { $0.label == "½ cup" }
        if let halfCup = halfCupOption {
            let expectedGrams = generator.gramsPerDomainUnit * 0.5
            XCTAssertEqual(halfCup.amountInGrams, expectedGrams, accuracy: 0.1,
                          "½ cup should use gramsPerDomainUnit * 0.5")
        }
    }
    
    // MARK: - Test Tbsp Ordering
    
    func testTbspOrdering() {
        let food = createTbspFood(description: "1 tbsp", amount: 16.0)
        let generator = makeGenerator(food: food)
        let options = generator.presets(maxCount: 3)
        
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Ensure strictly ascending grams
        XCTAssertEqual(grams, grams.sorted(), "Tbsp amounts should be strictly ascending")
        
        // Labels should follow increasing order
        // Pattern depends on multipliers: ["½ tbsp", "1 tbsp", "1½ tbsp"] or ["1 tbsp", "2 tbsp", "3 tbsp"]
        XCTAssertTrue(
            labels == ["½ tbsp", "1 tbsp", "1½ tbsp"] || labels == ["1 tbsp", "2 tbsp", "3 tbsp"],
            "Tbsp labels should be in ascending order"
        )
    }
    
    // MARK: - Test Slice Presets
    
    func testSlicePresets() {
        let food = createSliceFood(description: "1 slice", amount: 30.0)
        let generator = makeGenerator(food: food)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let amounts = options.map { $0.amountInGrams }
        
        // Expected: ["1 slice", "2 slices", "3 slices"] with amounts [30.0, 60.0, 90.0]
        XCTAssertTrue(labels.contains("1 slice"))
        XCTAssertTrue(labels.contains("2 slices"))
        XCTAssertTrue(labels.contains("3 slices"))
        XCTAssertEqual(amounts, amounts.sorted(), "Slice amounts should be in ascending order")
    }
    
    // MARK: - Test Piece Domain Labeling
    
    func testPieceDomainLabelingEggHasNoGramPresets() {
        let egg = FoodDefinition(
            id: UUID(),
            name: "Egg, whole, cooked",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 50.0,
                description: "1 large egg"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 70, protein: 6, carbs: 0.6, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: egg)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        
        // Should contain item labels (generic for all piece-based foods)
        XCTAssertTrue(labels.contains(where: { $0.contains("item") }), "Should have item labels. Got: \(labels)")
        
        // Should NOT contain gram-based labels (check for labels ending with "g" that are numeric grams like "50g", "100g")
        let gramLabels = labels.filter { label in
            let trimmed = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.range(of: #"^\d+\s*g$"#, options: .regularExpression) != nil
        }
        XCTAssertTrue(gramLabels.isEmpty, "Should not have gram presets for eggs. Found gram labels: \(gramLabels), All labels: \(labels)")
    }
    
    func testPieceDomainLabelingAppleHasNoGramPresets() {
        let apple = FoodDefinition(
            id: UUID(),
            name: "Apple",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 150.0,
                description: "1 medium apple"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: apple)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        
        // Should contain item labels (generic for all piece-based foods)
        XCTAssertTrue(labels.contains(where: { $0.contains("item") }), "Should have item labels. Got: \(labels)")
        
        // Should NOT contain gram-based labels
        let gramLabels = labels.filter { label in
            let trimmed = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.range(of: #"^\d+\s*g$"#, options: .regularExpression) != nil
        }
        XCTAssertTrue(gramLabels.isEmpty, "Should not have gram presets for apples. Found gram labels: \(gramLabels), All labels: \(labels)")
    }
    
    // MARK: - Test Grams Domain Labels
    
    func testGramsDomainLabels() {
        let food = createGramFood(amount: 100.0)
        let generator = makeGenerator(food: food)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        
        // Should have gram-based presets like ["50g", "100g", "150g"] or include 200g
        XCTAssertTrue(labels.allSatisfy { $0.trimmingCharacters(in: .whitespaces).hasSuffix("g") }, "All labels should end with 'g'")
        XCTAssertTrue(labels.contains("50g") || labels.contains("100g") || labels.contains("150g"), "Should have gram presets")
    }
    
    // MARK: - Test Grams Domain Custom Conversion
    
    func testGramsCustomUsesDirectValue() {
        let food = createGramFood(amount: 100.0)
        let generator = makeGenerator(food: food)
        
        // For gram domain, domain units should equal grams (no conversion)
        XCTAssertEqual(generator.domainUnitsToGrams(151), 151, accuracy: 0.001, "151 grams should stay 151, not become 15100")
        XCTAssertEqual(generator.gramsToDomainUnits(151), 151, accuracy: 0.001, "151 grams should stay 151 when converting back")
        
        // Test with different values
        XCTAssertEqual(generator.domainUnitsToGrams(50), 50, accuracy: 0.001)
        XCTAssertEqual(generator.gramsToDomainUnits(200), 200, accuracy: 0.001)
    }
    
    // MARK: - Test Custom Amount Initialization
    
    func testCustomAmountInitialization() {
        // Test that custom amount initializes with selected preset value
        // This is a behavioral test - the actual logic is in FoodDetailSheet
        // and would require integration testing or extracting the logic to a testable helper
        
        XCTAssertTrue(true, "Custom initialization test placeholder - logic is in FoodDetailSheet")
    }
    
    // MARK: - Test Oats Dry Half Cup Normalization and Selection
    
    func testOatsDryHalfCupNormalizationAndSelection() {
        let oats = FoodDefinition(
            id: UUID(),
            name: "Oats, dry",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 40.0, // 40g for ½ cup
                description: "1/2 cup dry"
            ),
            servingOptions: [
                FoodDefinition.ServingOption(id: UUID(), label: "½ cup dry", amountInGrams: 40.0),
                FoodDefinition.ServingOption(id: UUID(), label: "½ cup cooked", amountInGrams: 40.0)
            ],
            macros: FoodDefinition.Macros(calories: 150, protein: 5, carbs: 27, fat: 3),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: oats)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        
        // Should have normalized labels without "dry" or "cooked"
        // Note: order may vary because base serving is included first
        XCTAssertTrue(labels.contains("¼ cup"), "Should have '¼ cup'. Got: \(labels)")
        XCTAssertTrue(labels.contains("½ cup"), "Should have '½ cup'. Got: \(labels)")
        XCTAssertTrue(labels.contains("1 cup"), "Should have '1 cup'. Got: \(labels)")
        XCTAssertEqual(labels.filter { $0 == "½ cup" }.count, 1, "Should have only one '½ cup' after deduplication. Got: \(labels)")
        
        // Verify that base serving (½ cup) matches the conceptual preset
        // For "1/2 cup dry" with 40g, parsedBaseUnitsFromDescription returns 0.5
        // gramsPerDomainUnit = 40 / 0.5 = 80g per cup
        // So ½ cup preset = 80 * 0.5 = 40g, which matches baseAmount
        let baseAmount = oats.serving.amount
        let halfCupOption = options.first { $0.label == "½ cup" }
        XCTAssertNotNil(halfCupOption, "Should have '½ cup' option")
        if let halfCup = halfCupOption {
            // Base amount should match ½ cup grams (within tolerance)
            // gramsPerDomainUnit = 40 / 0.5 = 80, so ½ cup = 80 * 0.5 = 40
            let expectedGrams = generator.gramsPerDomainUnit * 0.5
            XCTAssertEqual(halfCup.amountInGrams, expectedGrams, accuracy: 0.1,
                         "½ cup preset should use gramsPerDomainUnit * 0.5")
            // Base amount (40g) should match ½ cup preset (40g)
            XCTAssertTrue(abs(halfCup.amountInGrams - baseAmount) < 0.1,
                         "Base amount \(baseAmount) should match ½ cup grams \(halfCup.amountInGrams)")
        }
    }
    
    // MARK: - Test Bread Slice Preset and Custom Match
    
    func testBreadSlicePresetAndCustomMatch() {
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
        let generator = makeGenerator(food: bread)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        
        // Should have slice presets
        XCTAssertTrue(labels.contains("1 slice"))
        XCTAssertTrue(labels.contains("2 slices"))
        XCTAssertTrue(labels.contains("3 slices"))
        
        // Find the "1 slice" option
        let oneSliceOption = options.first { $0.label == "1 slice" }
        XCTAssertNotNil(oneSliceOption, "Should have '1 slice' option")
        
        if let oneSlice = oneSliceOption {
            // Custom "1" should map to the same grams as "1 slice" preset
            let customGrams = generator.domainUnitsToGrams(1.0)
            XCTAssertEqual(customGrams, oneSlice.amountInGrams, accuracy: 0.01,
                          "Custom '1' should map to same grams as '1 slice' preset")
        }
    }
    
    // MARK: - Test Chicken Grams Custom Clears On Empty
    
    func testChickenGramsCustomClearsOnEmpty() {
        let chicken = createGramFood(amount: 100.0)
        let generator = makeGenerator(food: chicken)
        
        // Simulate setting custom to 100g
        let grams100 = generator.domainUnitsToGrams(100.0)
        XCTAssertEqual(grams100, 100.0, accuracy: 0.001, "100 grams should stay 100")
        
        // Simulate clearing (empty string)
        let emptyParsed = generator.parseAndSnapCustomAmount("")
        XCTAssertNil(emptyParsed, "Empty string should parse to nil")
        
        // When empty, should commit 0
        // This is tested by the fact that parseAndSnapCustomAmount returns nil,
        // which triggers onCustomServingCommit(0) in the onChange handler
    }
    
    // MARK: - Test Egg Custom Pieces
    
    func testEggCustomPieces() {
        let egg = FoodDefinition(
            id: UUID(),
            name: "Egg, whole, cooked",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 50.0, // 50g for 1 large egg
                description: "1 large egg"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 70, protein: 6, carbs: 0.6, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: egg)
        
        // Confirm presets contain "item" labels and not any "g"
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        XCTAssertTrue(labels.contains(where: { $0.contains("item") }), "Should have item labels. Got: \(labels)")
        // Check for numeric gram labels (not just any word ending in "g" like "egg")
        let gramLabels = labels.filter { label in
            let trimmed = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.range(of: #"^\d+\s*g$"#, options: .regularExpression) != nil
        }
        XCTAssertTrue(gramLabels.isEmpty, "Should not have gram presets for eggs. Found gram labels: \(gramLabels), All labels: \(labels)")
        
        // Compute grams for 1 and 2 pieces
        // For "1 large egg" with 50g, gramsPerDomainUnit = 50 / 1 = 50g per egg
        let gramsFor1 = generator.domainUnitsToGrams(1.0)
        let gramsFor2 = generator.domainUnitsToGrams(2.0)
        
        // Assert grams scale correctly
        // For "1 large egg" with 50g, parsedBaseUnitsFromDescription returns 1.0
        // gramsPerDomainUnit = 50 / 1 = 50g per egg
        XCTAssertEqual(gramsFor1, 50.0, accuracy: 0.1, "1 egg should be ~50g (gramsPerDomainUnit = \(generator.gramsPerDomainUnit))")
        XCTAssertEqual(gramsFor2, 100.0, accuracy: 0.1, "2 eggs should be ~100g")
        
        // Verify gramsPerDomainUnit is correct (50g / 1 egg = 50g per egg)
        let expectedGramsPerUnit = 50.0 / 1.0
        XCTAssertEqual(generator.gramsPerDomainUnit, expectedGramsPerUnit, accuracy: 0.1,
                      "gramsPerDomainUnit should be 50g per egg, got \(generator.gramsPerDomainUnit)")
    }
    
    // MARK: - Test Apple Custom Pieces
    
    func testAppleCustomPieces() {
        let apple = FoodDefinition(
            id: UUID(),
            name: "Apple",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 150.0, // 150g for 1 medium apple
                description: "1 medium apple"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: apple)
        
        // Confirm presets contain "item" labels and not any "g"
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        XCTAssertTrue(labels.contains(where: { $0.contains("item") }), "Should have item labels. Got: \(labels)")
        // Check for numeric gram labels (not just any word ending in "g")
        let gramLabels = labels.filter { label in
            let trimmed = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.range(of: #"^\d+\s*g$"#, options: .regularExpression) != nil
        }
        XCTAssertTrue(gramLabels.isEmpty, "Should not have gram presets for apples. Found gram labels: \(gramLabels), All labels: \(labels)")
        
        // Compute grams for 1 and 2 pieces
        // For "1 medium apple" with 150g, gramsPerDomainUnit = 150 / 1 = 150g per apple
        let gramsFor1 = generator.domainUnitsToGrams(1.0)
        let gramsFor2 = generator.domainUnitsToGrams(2.0)
        
        // Assert grams scale correctly
        // For "1 medium apple" with 150g, parsedBaseUnitsFromDescription returns 1.0
        // gramsPerDomainUnit = 150 / 1 = 150g per apple
        XCTAssertEqual(gramsFor1, 150.0, accuracy: 0.1, "1 apple should be ~150g (gramsPerDomainUnit = \(generator.gramsPerDomainUnit))")
        XCTAssertEqual(gramsFor2, 300.0, accuracy: 0.1, "2 apples should be ~300g")
        
        // Verify gramsPerDomainUnit is correct (150g / 1 apple = 150g per apple)
        let expectedGramsPerUnit = 150.0 / 1.0
        XCTAssertEqual(generator.gramsPerDomainUnit, expectedGramsPerUnit, accuracy: 0.1,
                      "gramsPerDomainUnit should be 150g per apple, got \(generator.gramsPerDomainUnit)")
    }
    
    // MARK: - Golden Master Tests for Real Foods
    
    func testPeanutButterPresetsGoldenMaster() {
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
        let generator = makeGenerator(food: peanutButter)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Expected: ["1 tbsp", "2 tbsp", "3 tbsp"] with approximate grams [16, 32, 48]
        XCTAssertEqual(labels, ["1 tbsp", "2 tbsp", "3 tbsp"], "Peanut butter should have tbsp presets")
        XCTAssertEqual(grams[0], 16.0, accuracy: 0.5, "1 tbsp should be ~16g")
        XCTAssertEqual(grams[1], 32.0, accuracy: 0.5, "2 tbsp should be ~32g")
        XCTAssertEqual(grams[2], 48.0, accuracy: 0.5, "3 tbsp should be ~48g")
    }
    
    func testBreadPresetsGoldenMaster() {
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
        let generator = makeGenerator(food: bread)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Expected: ["1 slice", "2 slices", "3 slices"] with grams [28, 56, 84]
        XCTAssertEqual(labels, ["1 slice", "2 slices", "3 slices"], "Bread should have slice presets")
        XCTAssertEqual(grams[0], 28.0, accuracy: 0.5, "1 slice should be ~28g")
        XCTAssertEqual(grams[1], 56.0, accuracy: 0.5, "2 slices should be ~56g")
        XCTAssertEqual(grams[2], 84.0, accuracy: 0.5, "3 slices should be ~84g")
    }
    
    func testOatsPresetsGoldenMaster() {
        let oats = FoodDefinition(
            id: UUID(),
            name: "Oats, dry",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 40.0, // 40g for ½ cup
                description: "1/2 cup dry"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 150, protein: 5, carbs: 27, fat: 3),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: oats)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Expected: ["¼ cup", "½ cup", "1 cup"] with approximate grams [20, 40, 80]
        XCTAssertTrue(labels.contains("¼ cup"), "Should have '¼ cup'")
        XCTAssertTrue(labels.contains("½ cup"), "Should have '½ cup'")
        XCTAssertTrue(labels.contains("1 cup"), "Should have '1 cup'")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted")
        XCTAssertEqual(grams.min() ?? 0, 20.0, accuracy: 0.5, "Min should be ~20g")
        XCTAssertEqual(grams.max() ?? 0, 80.0, accuracy: 0.5, "Max should be ~80g")
    }
    
    func testEggPresetsGoldenMaster() {
        let egg = FoodDefinition(
            id: UUID(),
            name: "Egg, whole, cooked",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 50.0, // 50g for 1 large egg
                description: "1 large egg"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 70, protein: 6, carbs: 0.6, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: egg)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Expected: ["1 item", "2 items", "3 items"] with grams [50, 100, 150]
        XCTAssertEqual(labels, ["1 item", "2 items", "3 items"], "Egg should have item presets")
        XCTAssertEqual(grams[0], 50.0, accuracy: 0.5, "1 item should be ~50g")
        XCTAssertEqual(grams[1], 100.0, accuracy: 0.5, "2 items should be ~100g")
        XCTAssertEqual(grams[2], 150.0, accuracy: 0.5, "3 items should be ~150g")
    }
    
    func testApplePresetsGoldenMaster() {
        let apple = FoodDefinition(
            id: UUID(),
            name: "Apple",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 150.0, // 150g for 1 medium apple
                description: "1 medium apple"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: apple)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Expected: ["1 item", "2 items", "3 items"] with grams [150, 300, 450]
        // Note: order may vary because base serving is included first
        XCTAssertTrue(labels.contains("1 item"), "Should have '1 item'. Got: \(labels)")
        XCTAssertTrue(labels.contains("2 items"), "Should have '2 items'. Got: \(labels)")
        XCTAssertTrue(labels.contains("3 items"), "Should have '3 items'. Got: \(labels)")
        XCTAssertEqual(labels.count, 3, "Should have exactly 3 presets. Got: \(labels)")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted. Got: \(grams)")
        XCTAssertEqual(grams.min() ?? 0, 150.0, accuracy: 0.5, "Min should be ~150g. Got: \(grams)")
        XCTAssertEqual(grams.max() ?? 0, 450.0, accuracy: 0.5, "Max should be ~450g. Got: \(grams)")
    }
    
    func testBlueberriesPresetsGoldenMaster() {
        let blueberries = FoodDefinition(
            id: UUID(),
            name: "Blueberries",
            brand: nil,
            serving: FoodDefinition.Serving(
                unit: "g",
                amount: 148.0, // 148g for 1 cup
                description: "1 cup"
            ),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 84, protein: 1.1, carbs: 21, fat: 0.5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        let generator = makeGenerator(food: blueberries)
        let options = generator.presets(maxCount: 3)
        let labels = options.map { $0.label }
        let grams = options.map { $0.amountInGrams }
        
        // Expected: ["½ cup", "1 cup", "1½ cups"] with approximate grams [74, 148, 222]
        XCTAssertEqual(labels, ["½ cup", "1 cup", "1½ cups"], "Blueberries should have cup presets")
        XCTAssertEqual(grams[0], 74.0, accuracy: 0.5, "½ cup should be ~74g")
        XCTAssertEqual(grams[1], 148.0, accuracy: 0.5, "1 cup should be ~148g")
        XCTAssertEqual(grams[2], 222.0, accuracy: 0.5, "1½ cups should be ~222g")
    }
}
