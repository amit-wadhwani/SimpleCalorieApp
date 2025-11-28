import Foundation

/// Remote food repository using USDA FoodData Central API
final class RemoteFoodRepository: FoodDefinitionRepository {
    private let fdcClient: FDCClientProtocol
    private var uuidToFdcId: [UUID: Int] = [:] // Cache mapping from UUID to FDC ID
    
    init(fdcClient: FDCClientProtocol = FDCClient()) {
        self.fdcClient = fdcClient
    }
    
    func searchFoods(query: String, limit: Int) async throws -> [FoodDefinition] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        // Call FDC search API
        // Handle missing API key gracefully
        let searchResponse: FDCSearchResponse
        do {
            searchResponse = try await fdcClient.searchFoods(query: trimmed, pageSize: limit)
        } catch FDCError.missingAPIKey {
            // Return empty results if API key is missing (better UX than crashing)
            return []
        }
        
        // Map search results to lightweight FoodDefinition
        // For search results, we use summary data and create minimal FoodDefinition
        // Full details will be loaded via loadFood(by:) when needed
        var results: [FoodDefinition] = []
        
        for summary in searchResponse.foods {
            // Generate UUID for this FDC ID
            let uuid = UUID()
            uuidToFdcId[uuid] = summary.fdcId
            
            // Determine serving from summary (prefer servingSize if available, else default to 100g)
            let servingAmount = summary.servingSize ?? 100.0
            let servingUnit = summary.servingSizeUnit ?? "g"
            let servingDescription = summary.householdServingFullText ?? "\(Int(servingAmount))\(servingUnit)"
            
            // Map macros from search response nutrients using shared helper
            let macros = FoodDefinition.Macros(from: summary.foodNutrients ?? [])
            
            // Create FoodDefinition from summary with real macros
            let food = FoodDefinition(
                id: uuid,
                name: summary.description,
                brand: summary.brandOwner,
                serving: FoodDefinition.Serving(unit: servingUnit, amount: servingAmount, description: servingDescription),
                servingOptions: nil,
                macros: macros,
                source: FoodDefinition.SourceMetadata(
                    kind: .usda,
                    providerId: String(summary.fdcId),
                    lastUpdatedAt: nil
                )
            )
            results.append(food)
        }
        
        return results
    }
    
    func loadFood(by id: UUID) async throws -> FoodDefinition {
        // Find FDC ID from UUID mapping
        guard let fdcId = uuidToFdcId[id] else {
            // If UUID not in mapping, we can't load it without the FDC ID
            // This can happen if the repository was recreated or the food wasn't from search
            throw FoodDefinitionRepositoryError.unavailable
        }
        
        // Fetch full details from FDC
        // Handle missing API key gracefully
        let details: FDCFoodDetailsResponse
        do {
            details = try await fdcClient.getFoodDetails(fdcId: fdcId)
        } catch FDCError.missingAPIKey {
            throw FoodDefinitionRepositoryError.unavailable
        }
        
        // Map to FoodDefinition, preserving the original UUID so future lookups work
        let food = FoodDefinition.fromFDC(details: details, preserveId: id)
        
        // Ensure UUID mapping is maintained (should already be set, but be safe)
        uuidToFdcId[food.id] = fdcId
        
        return food
    }
}

