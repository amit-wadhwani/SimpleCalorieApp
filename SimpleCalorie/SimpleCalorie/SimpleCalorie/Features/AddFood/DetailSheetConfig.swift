import Foundation

enum DetailSheetLayoutVariant: String, CaseIterable {
    case controlsAbove   // Serving + Quantity, then Calories/Macros/Donut
    case caloriesAbove   // Calories/Macros/Donut first, controls below
}

extension DetailSheetLayoutVariant {
    static let storageKey = "detailSheet.layoutVariant"
}

enum HeartStyleVariant: String, CaseIterable {
    case flat      // current simple SF Symbol
    case pill      // beveled pill background style
}

extension HeartStyleVariant {
    static let storageKey = "detailSheet.heartStyleVariant"
}

