import Foundation

protocol FoodSearchService {
    func search(query: String) async -> [Food]
}

