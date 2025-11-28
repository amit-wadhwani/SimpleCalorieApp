#if DEBUG
import Foundation

/// Result of a nutrient name sweep for a provider
struct NutrientNameSweepResult: Codable {
    let provider: String
    let searchCount: Int
    let detailCount: Int
    let uniqueNutrientNames: [String]
    let dateGenerated: Date
    
    enum CodingKeys: String, CodingKey {
        case provider
        case searchCount
        case detailCount
        case uniqueNutrientNames
        case dateGenerated
    }
    
    init(provider: String, searchCount: Int, detailCount: Int, uniqueNutrientNames: Set<String>) {
        self.provider = provider
        self.searchCount = searchCount
        self.detailCount = detailCount
        self.uniqueNutrientNames = Array(uniqueNutrientNames).sorted()
        self.dateGenerated = Date()
    }
}

/// Debug tool to sweep provider responses and collect unique nutrient names
@MainActor
final class NutrientNameSweeper {
    private let repository: FoodDefinitionRepository
    private let outputDirectory: URL
    
    init(repository: FoodDefinitionRepository) {
        self.repository = repository
        
        // Create DebugOutput directory in Documents
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.outputDirectory = documentsPath.appendingPathComponent("DebugOutput", isDirectory: true)
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    }
    
    /// Sweep FDC provider for nutrient names
    func sweepFDC() async throws -> NutrientNameSweepResult {
        // Verify we have a remote repository (though we'll use FDCClient directly)
        guard repository is RemoteFoodRepository else {
            throw SweeperError.notRemoteRepository
        }
        
        var uniqueNutrientNames: Set<String> = []
        var searchCount = 0
        var detailCount = 0
        
        // Use FDCClient directly to get nutrient names from actual API responses
        let fdcClient = FDCClient()
        var allNutrientNames: Set<String> = []
        
        // Sample a few foods to get nutrient names
        let sampleQueries = ["chicken", "apple", "oats", "egg", "bread"]
        for query in sampleQueries {
            do {
                let searchResponse = try await fdcClient.searchFoods(query: query, pageSize: 5)
                searchCount += searchResponse.foods.count
                
                for foodSummary in searchResponse.foods {
                    // Collect nutrient names from search response
                    if let nutrients = foodSummary.foodNutrients {
                        for nutrient in nutrients {
                            if let nutrientInfo = nutrient.nutrient {
                                allNutrientNames.insert(nutrientInfo.name)
                            }
                        }
                    }
                    
                    // Load details for each food
                    do {
                        let details = try await fdcClient.getFoodDetails(fdcId: foodSummary.fdcId)
                        detailCount += 1
                        
                        // Collect nutrient names from details response
                        if let nutrients = details.foodNutrients {
                            for nutrient in nutrients {
                                if let nutrientInfo = nutrient.nutrient {
                                    allNutrientNames.insert(nutrientInfo.name)
                                }
                            }
                        }
                    } catch {
                        print("⚠️ Sweep: Failed to load details for FDC ID \(foodSummary.fdcId): \(error)")
                    }
                }
            } catch {
                print("⚠️ Sweep: FDC search failed for '\(query)': \(error)")
            }
        }
        
        uniqueNutrientNames = allNutrientNames
        
        let result = NutrientNameSweepResult(
            provider: "FDC",
            searchCount: searchCount,
            detailCount: detailCount,
            uniqueNutrientNames: uniqueNutrientNames
        )
        
        // Write to file
        try writeResult(result, filename: "Seed_NutrientNames_fdc.json")
        
        return result
    }
    
    private func writeResult(_ result: NutrientNameSweepResult, filename: String) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(result)
        let fileURL = outputDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL)
        
        print("✅ Nutrient sweep complete: \(result.uniqueNutrientNames.count) unique nutrient names")
        print("📁 Saved to: \(fileURL.path)")
    }
}

enum SweeperError: Error {
    case notRemoteRepository
    case apiKeyMissing
    case networkError(Error)
}
#endif

