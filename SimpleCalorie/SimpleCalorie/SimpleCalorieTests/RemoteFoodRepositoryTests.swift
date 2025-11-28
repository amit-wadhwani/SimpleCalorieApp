import XCTest
@testable import SimpleCalorie

// MARK: - Mock FDCClient for Testing

final class MockFDCClient: FDCClientProtocol {
    var searchFoodsResult: FDCSearchResponse = FDCSearchResponse(foods: [], totalHits: nil, currentPage: nil, totalPages: nil)
    var getFoodDetailsResult: FDCFoodDetailsResponse?
    var getFoodDetailsError: Error?
    var searchFoodsError: Error?
    
    func searchFoods(query: String, pageSize: Int) async throws -> FDCSearchResponse {
        if let error = searchFoodsError {
            throw error
        }
        return searchFoodsResult
    }
    
    func getFoodDetails(fdcId: Int) async throws -> FDCFoodDetailsResponse {
        if let error = getFoodDetailsError {
            throw error
        }
        guard let result = getFoodDetailsResult else {
            throw FDCError.httpError(statusCode: 404)
        }
        return result
    }
}

@MainActor
final class RemoteFoodRepositoryTests: XCTestCase {
    
    func testCachingRepositoryPrefersLocalWhenAvailable() async throws {
        let local = TestFoodRepository()
        let remote = TestFoodRepository()
        let bread = FoodDefinition(
            id: UUID(),
            name: "Whole wheat bread",
            brand: "Test brand",
            serving: FoodDefinition.Serving(unit: "g", amount: 28, description: "1 slice"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 81, protein: 4, carbs: 14, fat: 1),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        local.foods = [bread]
        remote.foods = []
        
        let caching = CachingFoodRepository(local: local, remote: remote)
        
        let results = try await caching.searchFoods(query: "bread", limit: 5)
        XCTAssertEqual(results.count, 1, "Should find bread in local repository")
        XCTAssertEqual(results.first?.name, "Whole wheat bread")
        
        // Verify local was searched
        XCTAssertTrue(local.searchCalls.contains("bread"), "Local repository should be searched")
    }
    
    func testCachingRepositoryFallsBackToRemote() async throws {
        let local = TestFoodRepository()
        let remote = TestFoodRepository()
        let remoteFood = FoodDefinition(
            id: UUID(),
            name: "Remote Chicken",
            brand: "Remote brand",
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 165, protein: 31, carbs: 0, fat: 3.6),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        local.foods = []
        remote.foods = [remoteFood]
        
        let caching = CachingFoodRepository(local: local, remote: remote)
        
        let results = try await caching.searchFoods(query: "chicken", limit: 5)
        XCTAssertEqual(results.count, 1, "Should find chicken in remote repository")
        XCTAssertEqual(results.first?.name, "Remote Chicken")
        
        // Verify both were searched (local first, then remote)
        XCTAssertTrue(local.searchCalls.contains("chicken"), "Local repository should be searched first")
        XCTAssertTrue(remote.searchCalls.contains("chicken"), "Remote repository should be searched when local is empty")
    }
    
    func testCachingRepositoryCachesLoadedFoods() async throws {
        let local = TestFoodRepository()
        let remote = TestFoodRepository()
        let foodId = UUID()
        let food = FoodDefinition(
            id: foodId,
            name: "Cached Food",
            brand: nil,
            serving: FoodDefinition.Serving(unit: "g", amount: 100, description: "100g"),
            servingOptions: nil,
            macros: FoodDefinition.Macros(calories: 100, protein: 10, carbs: 10, fat: 5),
            source: FoodDefinition.SourceMetadata(kind: .localDemo, providerId: nil, lastUpdatedAt: nil)
        )
        local.foods = [food]
        remote.foods = []
        
        let caching = CachingFoodRepository(local: local, remote: remote)
        
        // Load food first
        let loaded = try await caching.loadFood(by: foodId)
        XCTAssertEqual(loaded.name, "Cached Food")
        
        // Clear local foods to simulate cache-only scenario
        local.foods = []
        
        // Should still be able to load from cache
        let cached = try await caching.loadFood(by: foodId)
        XCTAssertEqual(cached.name, "Cached Food", "Should load from cache even when local is empty")
    }
    
    func testRemoteRepositoryReturnsEmptyForSearch() async throws {
        // Use mock FDC client that returns empty results
        let mockClient = MockFDCClient()
        mockClient.searchFoodsResult = FDCSearchResponse(foods: [], totalHits: 0, currentPage: 1, totalPages: 0)
        let remote = RemoteFoodRepository(fdcClient: mockClient)
        let results = try await remote.searchFoods(query: "anything", limit: 10)
        XCTAssertEqual(results.count, 0, "Remote repository should return empty array when FDC returns no results")
    }
    
    func testRemoteRepositoryThrowsUnavailableForLoad() async throws {
        // Use mock FDC client
        let mockClient = MockFDCClient()
        let remote = RemoteFoodRepository(fdcClient: mockClient)
        let id = UUID()
        
        // UUID not in mapping, so should throw unavailable
        do {
            _ = try await remote.loadFood(by: id)
            XCTFail("Should throw unavailable error")
        } catch FoodDefinitionRepositoryError.unavailable {
            // Expected
        } catch {
            XCTFail("Should throw unavailable, got: \(error)")
        }
    }
    
    func testRemoteRepositoryHandlesFDCSearchResults() async throws {
        // Test that RemoteFoodRepository correctly maps FDC search results
        let mockClient = MockFDCClient()
        let fdcSummary = FDCFoodSummary(
            fdcId: 12345,
            description: "Test Food",
            brandOwner: "Test Brand",
            dataType: "Foundation",
            gtinUpc: nil,
            foodNutrients: nil,
            servingSize: nil,
            servingSizeUnit: nil,
            householdServingFullText: nil
        )
        mockClient.searchFoodsResult = FDCSearchResponse(
            foods: [fdcSummary],
            totalHits: 1,
            currentPage: 1,
            totalPages: 1
        )
        
        let remote = RemoteFoodRepository(fdcClient: mockClient)
        let results = try await remote.searchFoods(query: "test", limit: 10)
        
        XCTAssertEqual(results.count, 1, "Should return one result")
        XCTAssertEqual(results.first?.name, "Test Food")
        XCTAssertEqual(results.first?.brand, "Test Brand")
        XCTAssertEqual(results.first?.source.kind, .usda)
        XCTAssertEqual(results.first?.source.providerId, "12345")
    }
}

