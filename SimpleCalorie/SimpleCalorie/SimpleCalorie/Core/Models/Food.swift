import Foundation

struct Food: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let servingGrams: Int
    let macros: MacroInfo
    let kcal: Int
}

