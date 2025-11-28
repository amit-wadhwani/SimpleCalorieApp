import XCTest
@testable import SimpleCalorie

@MainActor
final class FDCMappingTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func loadFDCFixture(_ filename: String) throws -> FDCFoodDetailsResponse {
        // For oats_dry, always use embedded JSON (includes micronutrients)
        if filename == "oats_dry" {
            let data = oatsDryJSON.data(using: .utf8)!
            let decoder = JSONDecoder()
            return try decoder.decode(FDCFoodDetailsResponse.self, from: data)
        }
        
        // For all other fixtures, keep the existing bundle-first logic
        let testBundle = Bundle(for: type(of: self))
        var url = testBundle.url(forResource: filename, withExtension: "json", subdirectory: "FDCFixtures")
        
        if url == nil {
            url = testBundle.url(forResource: filename, withExtension: "json")
        }
        
        let data: Data
        if let fixtureURL = url {
            data = try Data(contentsOf: fixtureURL)
        } else {
            // Fallback: load from embedded JSON strings
            let jsonString: String
            switch filename {
            case "egg_whole_cooked":
                jsonString = eggWholeCookedJSON
            case "apple_medium":
                jsonString = appleMediumJSON
            case "peanut_butter":
                jsonString = peanutButterJSON
            case "blueberries":
                jsonString = blueberriesJSON
            default:
                throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(filename)"])
            }
            data = jsonString.data(using: .utf8)!
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(FDCFoodDetailsResponse.self, from: data)
    }
    
    // MARK: - Embedded Fixtures
    
    private let oatsDryJSON = """
    {
      "fdcId": 173944,
      "description": "Oats, dry",
      "brandOwner": null,
      "dataType": "Foundation",
      "foodPortions": [
        {
          "gramWeight": 40.0,
          "amount": 0.5,
          "modifier": "cup dry",
          "measureUnit": {
            "name": "cup",
            "abbreviation": "cup"
          }
        },
        {
          "gramWeight": 80.0,
          "amount": 1.0,
          "modifier": "cup dry",
          "measureUnit": {
            "name": "cup",
            "abbreviation": "cup"
          }
        },
        {
          "gramWeight": 100.0,
          "amount": 1.0,
          "modifier": null,
          "measureUnit": {
            "name": "gram",
            "abbreviation": "g"
          }
        }
      ],
      "foodNutrients": [
        {
          "nutrient": {
            "name": "Energy",
            "unitName": "kcal",
            "id": 1008
          },
          "amount": 389.0
        },
        {
          "nutrient": {
            "name": "Protein",
            "unitName": "g",
            "id": 1003
          },
          "amount": 16.9
        },
        {
          "nutrient": {
            "name": "Carbohydrate, by difference",
            "unitName": "g",
            "id": 1005
          },
          "amount": 66.3
        },
        {
          "nutrient": {
            "name": "Total lipid (fat)",
            "unitName": "g",
            "id": 1004
          },
          "amount": 6.9
        },
        {
          "nutrient": {
            "name": "Fiber, total dietary",
            "unitName": "G",
            "id": 1079
          },
          "amount": 10.6
        },
        {
          "nutrient": {
            "name": "Sugars, total including NLEA",
            "unitName": "G",
            "id": 2000
          },
          "amount": 0.99
        },
        {
          "nutrient": {
            "name": "Sodium, Na",
            "unitName": "MG",
            "id": 1093
          },
          "amount": 2.0
        },
        {
          "nutrient": {
            "name": "Cholesterol",
            "unitName": "MG",
            "id": 1253
          },
          "amount": 0.0
        },
        {
          "nutrient": {
            "name": "Potassium, K",
            "unitName": "MG",
            "id": 1092
          },
          "amount": 429.0
        }
      ]
    }
    """
    
    private let eggWholeCookedJSON = """
    {
      "fdcId": 173424,
      "description": "Egg, whole, cooked, hard-boiled",
      "brandOwner": null,
      "dataType": "Foundation",
      "foodPortions": [
        {
          "gramWeight": 50.0,
          "amount": 1.0,
          "modifier": "large egg",
          "measureUnit": {
            "name": "item",
            "abbreviation": "item"
          }
        },
        {
          "gramWeight": 100.0,
          "amount": 1.0,
          "modifier": null,
          "measureUnit": {
            "name": "gram",
            "abbreviation": "g"
          }
        }
      ],
      "foodNutrients": [
        {
          "nutrient": {
            "name": "Energy",
            "unitName": "kcal",
            "id": 1008
          },
          "amount": 155.0
        },
        {
          "nutrient": {
            "name": "Protein",
            "unitName": "g",
            "id": 1003
          },
          "amount": 12.6
        },
        {
          "nutrient": {
            "name": "Carbohydrate, by difference",
            "unitName": "g",
            "id": 1005
          },
          "amount": 1.12
        },
        {
          "nutrient": {
            "name": "Total lipid (fat)",
            "unitName": "g",
            "id": 1004
          },
          "amount": 10.6
        }
      ]
    }
    """
    
    private let appleMediumJSON = """
    {
      "fdcId": 171688,
      "description": "Apple, raw, with skin",
      "brandOwner": null,
      "dataType": "Foundation",
      "foodPortions": [
        {
          "gramWeight": 182.0,
          "amount": 1.0,
          "modifier": "medium apple",
          "measureUnit": {
            "name": "item",
            "abbreviation": "item"
          }
        },
        {
          "gramWeight": 100.0,
          "amount": 1.0,
          "modifier": null,
          "measureUnit": {
            "name": "gram",
            "abbreviation": "g"
          }
        }
      ],
      "foodNutrients": [
        {
          "nutrient": {
            "name": "Energy",
            "unitName": "kcal",
            "id": 1008
          },
          "amount": 52.0
        },
        {
          "nutrient": {
            "name": "Protein",
            "unitName": "g",
            "id": 1003
          },
          "amount": 0.26
        },
        {
          "nutrient": {
            "name": "Carbohydrate, by difference",
            "unitName": "g",
            "id": 1005
          },
          "amount": 13.81
        },
        {
          "nutrient": {
            "name": "Total lipid (fat)",
            "unitName": "g",
            "id": 1004
          },
          "amount": 0.17
        }
      ]
    }
    """
    
    private let peanutButterJSON = """
    {
      "fdcId": 172430,
      "description": "Peanut butter, smooth style, with salt",
      "brandOwner": null,
      "dataType": "Foundation",
      "foodPortions": [
        {
          "gramWeight": 16.0,
          "amount": 1.0,
          "modifier": "tbsp",
          "measureUnit": {
            "name": "tablespoon",
            "abbreviation": "tbsp"
          }
        },
        {
          "gramWeight": 32.0,
          "amount": 2.0,
          "modifier": "tbsp",
          "measureUnit": {
            "name": "tablespoon",
            "abbreviation": "tbsp"
          }
        },
        {
          "gramWeight": 100.0,
          "amount": 1.0,
          "modifier": null,
          "measureUnit": {
            "name": "gram",
            "abbreviation": "g"
          }
        }
      ],
      "foodNutrients": [
        {
          "nutrient": {
            "name": "Energy",
            "unitName": "kcal",
            "id": 1008
          },
          "amount": 588.0
        },
        {
          "nutrient": {
            "name": "Protein",
            "unitName": "g",
            "id": 1003
          },
          "amount": 25.09
        },
        {
          "nutrient": {
            "name": "Carbohydrate, by difference",
            "unitName": "g",
            "id": 1005
          },
          "amount": 19.56
        },
        {
          "nutrient": {
            "name": "Total lipid (fat)",
            "unitName": "g",
            "id": 1004
          },
          "amount": 50.39
        }
      ]
    }
    """
    
    private let blueberriesJSON = """
    {
      "fdcId": 173944,
      "description": "Blueberries, raw",
      "brandOwner": null,
      "dataType": "Foundation",
      "foodPortions": [
        {
          "gramWeight": 148.0,
          "amount": 1.0,
          "modifier": "cup",
          "measureUnit": {
            "name": "cup",
            "abbreviation": "cup"
          }
        },
        {
          "gramWeight": 74.0,
          "amount": 0.5,
          "modifier": "cup",
          "measureUnit": {
            "name": "cup",
            "abbreviation": "cup"
          }
        },
        {
          "gramWeight": 100.0,
          "amount": 1.0,
          "modifier": null,
          "measureUnit": {
            "name": "gram",
            "abbreviation": "g"
          }
        }
      ],
      "foodNutrients": [
        {
          "nutrient": {
            "name": "Energy",
            "unitName": "kcal",
            "id": 1008
          },
          "amount": 57.0
        },
        {
          "nutrient": {
            "name": "Protein",
            "unitName": "g",
            "id": 1003
          },
          "amount": 0.74
        },
        {
          "nutrient": {
            "name": "Carbohydrate, by difference",
            "unitName": "g",
            "id": 1005
          },
          "amount": 14.49
        },
        {
          "nutrient": {
            "name": "Total lipid (fat)",
            "unitName": "g",
            "id": 1004
          },
          "amount": 0.33
        }
      ]
    }
    """
    
    // MARK: - Oats Tests
    
    func testOatsMappingAndServingPresets() throws {
        let fdcDetails = try loadFDCFixture("oats_dry")
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Verify basic mapping
        XCTAssertEqual(food.name, "Oats, dry")
        XCTAssertEqual(food.source.kind, .usda)
        XCTAssertEqual(food.source.providerId, "173944")
        
        // Verify macros (per 100g from FDC)
        XCTAssertGreaterThan(food.macros.calories, 0, "Calories should be > 0 for oats")
        XCTAssertEqual(food.macros.calories, 389, accuracy: 1)
        XCTAssertGreaterThan(food.macros.protein, 0, "Protein should be > 0 for oats")
        XCTAssertEqual(food.macros.protein, 16.9, accuracy: 0.1)
        XCTAssertGreaterThan(food.macros.carbs, 0, "Carbs should be > 0 for oats")
        XCTAssertEqual(food.macros.carbs, 66.3, accuracy: 0.1)
        XCTAssertGreaterThan(food.macros.fat, 0, "Fat should be > 0 for oats")
        XCTAssertEqual(food.macros.fat, 6.9, accuracy: 0.1)
        
        // Verify micronutrients
        XCTAssertNotNil(food.micronutrients, "Micronutrients should be present for oats")
        if let micros = food.micronutrients {
            XCTAssertEqual(micros.fiber, 10.6, accuracy: 0.1, "Fiber should be ~10.6g per 100g")
            XCTAssertEqual(micros.sugar, 0.99, accuracy: 0.1, "Sugar should be ~0.99g per 100g")
            XCTAssertEqual(micros.sodium, 2.0, accuracy: 1.0, "Sodium should be ~2mg per 100g")
            XCTAssertEqual(micros.cholesterol, 0.0, accuracy: 0.1, "Cholesterol should be ~0mg per 100g")
            XCTAssertEqual(micros.potassium, 429.0, accuracy: 1.0, "Potassium should be ~429mg per 100g")
        }
        
        // Verify serving (should be 0.5 cup = 40g based on first portion with amount=1)
        // Actually, we prefer amount=1 with modifier, so 1 cup = 80g
        XCTAssertTrue(food.serving.description?.contains("cup") ?? false, "Serving should contain 'cup'")
        
        // Test ServingSizeGenerator
        let generator = ServingSizeGenerator(food: food)
        let presets = generator.presets(maxCount: 3)
        let labels = presets.map { $0.label }
        let grams = presets.map { $0.amountInGrams }
        
        // Should have cup-based presets
        XCTAssertTrue(labels.contains(where: { $0.contains("cup") }), "Should have cup presets. Got: \(labels)")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted ascending")
        XCTAssertGreaterThan(grams.max() ?? 0, grams.min() ?? 0, "Should have multiple preset sizes")
        
        // Verify gramsPerDomainUnit is reasonable (should be around 80g per cup)
        XCTAssertGreaterThan(generator.gramsPerDomainUnit, 50, "gramsPerDomainUnit should be reasonable")
        XCTAssertLessThan(generator.gramsPerDomainUnit, 150, "gramsPerDomainUnit should be reasonable")
    }
    
    // MARK: - Egg Tests
    
    func testEggMappingAndServingPresets() throws {
        let fdcDetails = try loadFDCFixture("egg_whole_cooked")
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Verify basic mapping
        XCTAssertEqual(food.name, "Egg, whole, cooked, hard-boiled")
        XCTAssertEqual(food.source.kind, .usda)
        
        // Verify macros (per 100g, but we'll test per egg = 50g)
        // Per 100g: 155 kcal, 12.6g protein, 1.12g carbs, 10.6g fat
        // Per 50g (1 egg): ~77.5 kcal, 6.3g protein, 0.56g carbs, 5.3g fat
        XCTAssertGreaterThan(food.macros.calories, 0)
        
        // Test ServingSizeGenerator
        let generator = ServingSizeGenerator(food: food)
        let presets = generator.presets(maxCount: 3)
        let labels = presets.map { $0.label }
        let grams = presets.map { $0.amountInGrams }
        
        // Should have item-based presets (1 item, 2 items, 3 items)
        XCTAssertTrue(labels.contains("1 item"), "Should have '1 item'. Got: \(labels)")
        XCTAssertTrue(labels.contains("2 items"), "Should have '2 items'. Got: \(labels)")
        XCTAssertTrue(labels.contains("3 items"), "Should have '3 items'. Got: \(labels)")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted ascending")
        
        // Verify gramsPerDomainUnit is around 50g per egg
        XCTAssertEqual(generator.gramsPerDomainUnit, 50.0, accuracy: 5.0, "gramsPerDomainUnit should be ~50g per egg")
    }
    
    // MARK: - Apple Tests
    
    func testAppleMappingAndServingPresets() throws {
        let fdcDetails = try loadFDCFixture("apple_medium")
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Verify basic mapping
        XCTAssertEqual(food.name, "Apple, raw, with skin")
        XCTAssertEqual(food.source.kind, .usda)
        
        // Verify macros
        XCTAssertGreaterThan(food.macros.calories, 0, "Calories should be > 0 for egg")
        XCTAssertGreaterThan(food.macros.protein, 0, "Protein should be > 0 for egg")
        XCTAssertGreaterThanOrEqual(food.macros.carbs, 0, "Carbs should be >= 0 for egg")
        XCTAssertGreaterThan(food.macros.fat, 0, "Fat should be > 0 for egg")
        
        // Test ServingSizeGenerator
        let generator = ServingSizeGenerator(food: food)
        let presets = generator.presets(maxCount: 3)
        let labels = presets.map { $0.label }
        let grams = presets.map { $0.amountInGrams }
        
        // Should have item-based presets
        XCTAssertTrue(labels.contains("1 item"), "Should have '1 item'. Got: \(labels)")
        XCTAssertTrue(labels.contains("2 items"), "Should have '2 items'. Got: \(labels)")
        XCTAssertTrue(labels.contains("3 items"), "Should have '3 items'. Got: \(labels)")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted ascending")
        
        // Verify gramsPerDomainUnit is around 182g per apple
        XCTAssertEqual(generator.gramsPerDomainUnit, 182.0, accuracy: 10.0, "gramsPerDomainUnit should be ~182g per apple")
    }
    
    // MARK: - Peanut Butter Tests
    
    func testPeanutButterMappingAndServingPresets() throws {
        let fdcDetails = try loadFDCFixture("peanut_butter")
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Verify basic mapping
        XCTAssertEqual(food.name, "Peanut butter, smooth style, with salt")
        XCTAssertEqual(food.source.kind, .usda)
        
        // Verify macros (per 100g: 588 kcal, 25.09g protein, 19.56g carbs, 50.39g fat)
        XCTAssertGreaterThan(food.macros.calories, 0, "Calories should be > 0 for peanut butter")
        XCTAssertEqual(food.macros.calories, 588, accuracy: 10)
        XCTAssertGreaterThan(food.macros.protein, 0, "Protein should be > 0 for peanut butter")
        XCTAssertEqual(food.macros.protein, 25.09, accuracy: 1.0)
        XCTAssertGreaterThan(food.macros.carbs, 0, "Carbs should be > 0 for peanut butter")
        XCTAssertEqual(food.macros.carbs, 19.56, accuracy: 1.0)
        XCTAssertGreaterThan(food.macros.fat, 0, "Fat should be > 0 for peanut butter")
        XCTAssertEqual(food.macros.fat, 50.39, accuracy: 1.0)
        
        // Test ServingSizeGenerator
        let generator = ServingSizeGenerator(food: food)
        let presets = generator.presets(maxCount: 3)
        let labels = presets.map { $0.label }
        let grams = presets.map { $0.amountInGrams }
        
        // Should have tbsp-based presets
        XCTAssertTrue(labels.contains(where: { $0.contains("tbsp") }), "Should have tbsp presets. Got: \(labels)")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted ascending")
        
        // Verify gramsPerDomainUnit is around 16g per tbsp
        XCTAssertEqual(generator.gramsPerDomainUnit, 16.0, accuracy: 2.0, "gramsPerDomainUnit should be ~16g per tbsp")
    }
    
    // MARK: - Blueberries Tests
    
    func testBlueberriesMappingAndServingPresets() throws {
        let fdcDetails = try loadFDCFixture("blueberries")
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Verify basic mapping
        XCTAssertEqual(food.name, "Blueberries, raw")
        XCTAssertEqual(food.source.kind, .usda)
        
        // Verify macros (per 100g: 57 kcal, 0.74g protein, 14.49g carbs, 0.33g fat)
        XCTAssertGreaterThan(food.macros.calories, 0, "Calories should be > 0 for blueberries")
        XCTAssertEqual(food.macros.calories, 57, accuracy: 5)
        XCTAssertGreaterThanOrEqual(food.macros.protein, 0, "Protein should be >= 0 for blueberries")
        XCTAssertEqual(food.macros.protein, 0.74, accuracy: 0.1)
        XCTAssertGreaterThan(food.macros.carbs, 0, "Carbs should be > 0 for blueberries")
        XCTAssertEqual(food.macros.carbs, 14.49, accuracy: 1.0)
        XCTAssertGreaterThanOrEqual(food.macros.fat, 0, "Fat should be >= 0 for blueberries")
        XCTAssertEqual(food.macros.fat, 0.33, accuracy: 0.1)
        
        // Test ServingSizeGenerator
        let generator = ServingSizeGenerator(food: food)
        let presets = generator.presets(maxCount: 3)
        let labels = presets.map { $0.label }
        let grams = presets.map { $0.amountInGrams }
        
        // Should have cup-based presets
        XCTAssertTrue(labels.contains(where: { $0.contains("cup") }), "Should have cup presets. Got: \(labels)")
        XCTAssertEqual(grams.sorted(), grams, "Grams should be sorted ascending")
        
        // Verify gramsPerDomainUnit is around 148g per cup
        XCTAssertEqual(generator.gramsPerDomainUnit, 148.0, accuracy: 10.0, "gramsPerDomainUnit should be ~148g per cup")
        
        // Verify presets are reasonable (should include ½ cup, 1 cup, 1½ cups or similar)
        XCTAssertGreaterThan(grams.min() ?? 0, 50, "Min preset should be reasonable")
        XCTAssertLessThan(grams.max() ?? 0, 300, "Max preset should be reasonable")
    }
    
    // MARK: - Edge Cases
    
    func testFDCMappingWithMissingPortions() throws {
        // Create a minimal FDC response with no portions
        let minimalJSON = """
        {
          "fdcId": 999999,
          "description": "Test Food",
          "brandOwner": null,
          "dataType": "Foundation",
          "foodPortions": null,
          "foodNutrients": [
            {
              "nutrient": {
                "name": "Energy",
                "unitName": "kcal",
                "id": 1008
              },
              "amount": 100.0
            }
          ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let fdcDetails = try decoder.decode(FDCFoodDetailsResponse.self, from: minimalJSON)
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Should fallback to 100g serving
        XCTAssertEqual(food.serving.amount, 100.0, accuracy: 0.1)
        XCTAssertEqual(food.serving.unit, "g")
        XCTAssertEqual(food.serving.description, "100g")
    }
    
    func testFDCMappingWithMissingNutrients() throws {
        // Create a minimal FDC response with no nutrients
        let minimalJSON = """
        {
          "fdcId": 999998,
          "description": "Test Food No Nutrients",
          "brandOwner": null,
          "dataType": "Foundation",
          "foodPortions": [
            {
              "gramWeight": 100.0,
              "amount": 1.0,
              "modifier": null,
              "measureUnit": {
                "name": "gram",
                "abbreviation": "g"
              }
            }
          ],
          "foodNutrients": null
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let fdcDetails = try decoder.decode(FDCFoodDetailsResponse.self, from: minimalJSON)
        let food = FoodDefinition.fromFDC(details: fdcDetails)
        
        // Should default to 0 macros
        XCTAssertEqual(food.macros.calories, 0)
        XCTAssertEqual(food.macros.protein, 0)
        XCTAssertEqual(food.macros.carbs, 0)
        XCTAssertEqual(food.macros.fat, 0)
    }
    
    // MARK: - Search Response Mapping Tests
    
    func testSearchResponseMappingWithMacros() throws {
        // Test mapping macros from FDC search response (chicken breast example)
        // Uses real search-style JSON shape: { "nutrientName": "...", "unitName": "...", "nutrientId": ..., "value": 123 }
        let searchResponseJSON = """
        {
          "foods": [
            {
              "fdcId": 171077,
              "description": "Chicken, broiler, rotisserie, BBQ, breast meat only",
              "brandOwner": null,
              "dataType": "SR Legacy",
              "gtinUpc": null,
              "foodNutrients": [
                {
                  "nutrientId": 1008,
                  "nutrientName": "Energy",
                  "unitName": "KCAL",
                  "value": 107.0
                },
                {
                  "nutrientId": 1003,
                  "nutrientName": "Protein",
                  "unitName": "G",
                  "value": 21.4
                },
                {
                  "nutrientId": 1005,
                  "nutrientName": "Carbohydrate, by difference",
                  "unitName": "G",
                  "value": 0.0
                },
                {
                  "nutrientId": 1004,
                  "nutrientName": "Total lipid (fat)",
                  "unitName": "G",
                  "value": 1.8
                }
              ],
              "servingSize": 100.0,
              "servingSizeUnit": "g",
              "householdServingFullText": "100g"
            }
          ],
          "totalHits": 1,
          "currentPage": 1,
          "totalPages": 1
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(FDCSearchResponse.self, from: searchResponseJSON)
        
        // Verify we have one food
        XCTAssertEqual(searchResponse.foods.count, 1)
        let summary = searchResponse.foods[0]
        
        // Map macros from search summary using shared helper
        let macros = FoodDefinition.Macros(from: summary.foodNutrients ?? [])
        
        // Assert macros are correctly mapped
        XCTAssertGreaterThan(macros.calories, 0, "Calories should be > 0 for chicken")
        XCTAssertEqual(macros.calories, 107, accuracy: 1, "Chicken calories should be ~107 kcal per 100g")
        
        XCTAssertGreaterThan(macros.protein, 0, "Protein should be > 0 for chicken")
        XCTAssertEqual(macros.protein, 21.4, accuracy: 0.5, "Chicken protein should be ~21.4g per 100g")
        
        XCTAssertGreaterThanOrEqual(macros.carbs, 0, "Carbs should be >= 0 for chicken")
        XCTAssertEqual(macros.carbs, 0.0, accuracy: 0.1, "Chicken carbs should be ~0g per 100g")
        
        XCTAssertGreaterThanOrEqual(macros.fat, 0, "Fat should be >= 0 for chicken")
        XCTAssertEqual(macros.fat, 1.8, accuracy: 0.2, "Chicken fat should be ~1.8g per 100g")
        
        // Test that RemoteFoodRepository would create a FoodDefinition with these macros
        let uuid = UUID()
        let food = FoodDefinition(
            id: uuid,
            name: summary.description,
            brand: summary.brandOwner,
            serving: FoodDefinition.Serving(
                unit: summary.servingSizeUnit ?? "g",
                amount: summary.servingSize ?? 100.0,
                description: summary.householdServingFullText ?? "100g"
            ),
            servingOptions: nil,
            macros: macros,
            source: FoodDefinition.SourceMetadata(
                kind: .usda,
                providerId: String(summary.fdcId),
                lastUpdatedAt: nil
            )
        )
        
        // Verify the food has correct macros
        XCTAssertEqual(food.macros.calories, 107, accuracy: 1)
        XCTAssertEqual(food.macros.protein, 21.4, accuracy: 0.5)
        XCTAssertEqual(food.macros.carbs, 0.0, accuracy: 0.1)
        XCTAssertEqual(food.macros.fat, 1.8, accuracy: 0.2)
    }
}

