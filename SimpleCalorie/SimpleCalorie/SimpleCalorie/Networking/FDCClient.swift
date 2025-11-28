import Foundation

/// Protocol for FDC client to enable testing
protocol FDCClientProtocol {
    func searchFoods(query: String, pageSize: Int) async throws -> FDCSearchResponse
    func getFoodDetails(fdcId: Int) async throws -> FDCFoodDetailsResponse
}

/// Client for USDA FoodData Central API
final class FDCClient: FDCClientProtocol {
    private let apiKey: String?
    private let baseURL: String
    private let session: URLSession
    
    /// Initialize with API key from FDCClientConfig
    /// - Parameters:
    ///   - apiKey: Optional API key (if nil, will attempt to load from FDCClientConfig)
    ///   - baseURL: Base URL for FDC API
    ///   - session: URLSession for network requests
    init(apiKey: String? = nil, baseURL: String = "https://api.nal.usda.gov/fdc/v1", session: URLSession = .shared) {
        // Use provided key, or fall back to config, or nil
        self.apiKey = apiKey ?? FDCClientConfig.shared.apiKey
        self.baseURL = baseURL
        self.session = session
    }
    
    /// Validates that API key is available, throws if missing
    private func requireAPIKey() throws -> String {
        guard let key = apiKey, !key.isEmpty else {
            throw FDCError.missingAPIKey
        }
        return key
    }
    
    /// Search foods in FDC
    /// - Parameters:
    ///   - query: Search query string
    ///   - pageSize: Maximum number of results (default 50)
    /// - Returns: FDCSearchResponse with matching foods
    func searchFoods(query: String, pageSize: Int = 50) async throws -> FDCSearchResponse {
        let key = try requireAPIKey()
        
        var components = URLComponents(string: "\(baseURL)/foods/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "api_key", value: key)
        ]
        
        guard let url = components.url else {
            throw FDCError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FDCError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw FDCError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(FDCSearchResponse.self, from: data)
    }
    
    /// Get detailed food information by FDC ID
    /// - Parameter fdcId: FDC food ID
    /// - Returns: FDCFoodDetailsResponse with full food details
    func getFoodDetails(fdcId: Int) async throws -> FDCFoodDetailsResponse {
        let key = try requireAPIKey()
        
        var components = URLComponents(string: "\(baseURL)/food/\(fdcId)")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: key)
        ]
        
        guard let url = components.url else {
            throw FDCError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FDCError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw FDCError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(FDCFoodDetailsResponse.self, from: data)
    }
}

// MARK: - FDC Errors

enum FDCError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case missingAPIKey
}

// MARK: - FDC DTOs

struct FDCSearchResponse: Decodable {
    let foods: [FDCFoodSummary]
    let totalHits: Int?
    let currentPage: Int?
    let totalPages: Int?
}

struct FDCFoodSummary: Decodable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let dataType: String?
    let gtinUpc: String?
    let foodNutrients: [FDCFoodNutrient]?
    let servingSize: Double?
    let servingSizeUnit: String?
    let householdServingFullText: String?
}

struct FDCFoodDetailsResponse: Decodable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let dataType: String?
    let foodPortions: [FDCFoodPortion]?
    let foodNutrients: [FDCFoodNutrient]?
}

struct FDCFoodPortion: Decodable {
    let gramWeight: Double?
    let amount: Double?
    let modifier: String?
    let measureUnit: FDCMeasureUnit?
}

struct FDCMeasureUnit: Decodable {
    let name: String?
    let abbreviation: String?
}

struct FDCFoodNutrient: Decodable {
    let nutrient: FDCNutrient?
    let amount: Double?
    
    private enum CodingKeys: String, CodingKey {
        case nutrient
        case amount
        // search-style keys
        case nutrientName
        case unitName
        case nutrientId
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try detail-style shape first: { "nutrient": { ... }, "amount": 123 }
        // Check if we have the detail-style structure (either nutrient object or amount key)
        if container.contains(.nutrient) || container.contains(.amount) {
            let nested = try container.decodeIfPresent(FDCNutrient.self, forKey: .nutrient)
            let amount = try container.decodeIfPresent(Double.self, forKey: .amount)
            self.nutrient = nested
            self.amount = amount
            return
        }
        
        // Fallback: search-style shape: { "nutrientName": "...", "unitName": "...", "nutrientId": ..., "value": 123 }
        // This is the flat structure used in FDC search responses
        let name = try container.decodeIfPresent(String.self, forKey: .nutrientName)
        let unit = try container.decodeIfPresent(String.self, forKey: .unitName)
        let id = try container.decodeIfPresent(Int.self, forKey: .nutrientId)
        let value = try container.decodeIfPresent(Double.self, forKey: .value)
        
        // Construct FDCNutrient from flat search-style fields
        if let name = name {
            self.nutrient = FDCNutrient(name: name, unitName: unit, id: id)
        } else {
            self.nutrient = nil
        }
        self.amount = value
    }
}

struct FDCNutrient: Decodable {
    let name: String
    let unitName: String?
    let id: Int?
}

