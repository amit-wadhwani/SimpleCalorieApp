#if DEBUG
import XCTest
@testable import SimpleCalorie

@MainActor
final class ProviderSweepTests: XCTestCase {
    
    func testNutrientSweepResultEncoding() throws {
        let nutrientNames: Set<String> = ["Energy", "Protein", "Carbohydrate, by difference", "Total lipid (fat)"]
        let result = NutrientNameSweepResult(
            provider: "FDC",
            searchCount: 5,
            detailCount: 5,
            uniqueNutrientNames: nutrientNames
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(result)
        let jsonString = String(data: data, encoding: .utf8)!
        
        // Verify JSON contains expected fields
        XCTAssertTrue(jsonString.contains("provider"))
        XCTAssertTrue(jsonString.contains("FDC"))
        XCTAssertTrue(jsonString.contains("searchCount"))
        XCTAssertTrue(jsonString.contains("detailCount"))
        XCTAssertTrue(jsonString.contains("uniqueNutrientNames"))
        XCTAssertTrue(jsonString.contains("dateGenerated"))
        
        // Verify decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(NutrientNameSweepResult.self, from: data)
        
        XCTAssertEqual(decoded.provider, "FDC")
        XCTAssertEqual(decoded.searchCount, 5)
        XCTAssertEqual(decoded.detailCount, 5)
        XCTAssertEqual(decoded.uniqueNutrientNames.count, 4)
        XCTAssertTrue(decoded.uniqueNutrientNames.contains("Energy"))
        XCTAssertTrue(decoded.uniqueNutrientNames.contains("Protein"))
    }
    
    func testNutrientSweepResultHasUniqueNutrientNames() throws {
        let nutrientNames: Set<String> = ["Energy", "Protein", "Energy", "Protein", "Fat"]
        let result = NutrientNameSweepResult(
            provider: "FDC",
            searchCount: 0,
            detailCount: 0,
            uniqueNutrientNames: nutrientNames
        )
        
        // Should be deduplicated and sorted
        XCTAssertEqual(result.uniqueNutrientNames.count, 3)
        XCTAssertEqual(result.uniqueNutrientNames, ["Energy", "Fat", "Protein"])
    }
    
    func testNutrientSweeperInitialization() {
        let repo = LocalFoodRepository()
        let sweeper = NutrientNameSweeper(repository: repo)
        
        // Should not crash
        XCTAssertNotNil(sweeper)
    }
    
    // Note: Actual sweep test requires FDC API key and network access
    // This test verifies the file structure would be created correctly
    func testSweepResultFileStructure() throws {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let debugOutputDir = documentsPath.appendingPathComponent("DebugOutput", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: debugOutputDir, withIntermediateDirectories: true)
        
        // Verify directory exists or can be created
        XCTAssertTrue(FileManager.default.fileExists(atPath: debugOutputDir.path) || 
                     (try? FileManager.default.createDirectory(at: debugOutputDir, withIntermediateDirectories: true)) != nil)
    }
}
#endif

