import Foundation
import SwiftUI

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteFoodIDs: Set<UUID> = []
    
    private let storageKey = "favoriteFoodIDs"
    
    init() {
        loadFavorites()
    }
    
    func isFavorite(_ foodID: UUID) -> Bool {
        favoriteFoodIDs.contains(foodID)
    }
    
    func toggleFavorite(_ foodID: UUID) {
        if favoriteFoodIDs.contains(foodID) {
            favoriteFoodIDs.remove(foodID)
        } else {
            favoriteFoodIDs.insert(foodID)
        }
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            favoriteFoodIDs = Set(decoded)
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(Array(favoriteFoodIDs)) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

