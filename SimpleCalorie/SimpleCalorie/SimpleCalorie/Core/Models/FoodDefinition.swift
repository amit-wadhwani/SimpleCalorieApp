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
    let source: SourceMetadata
}

