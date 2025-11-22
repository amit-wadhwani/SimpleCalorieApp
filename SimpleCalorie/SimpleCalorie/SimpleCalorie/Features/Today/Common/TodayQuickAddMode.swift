import Foundation

enum TodayQuickAddMode: String, CaseIterable {
    case suggestions
    case swipe
    case both
    
    static let storageKey = "today.quickAddMode"
    
    var displayName: String {
        switch self {
        case .suggestions: return "Suggestions"
        case .swipe:       return "Swipe"
        case .both:        return "Both"
        }
    }
}

enum TodaySuggestionsLayoutMode: String, CaseIterable {
    case horizontal
    case vertical
    
    static let storageKey = "today.suggestionsLayoutMode"
    
    var displayName: String {
        switch self {
        case .horizontal: return "Horizontal"
        case .vertical:   return "Vertical"
        }
    }
}

enum TodaySwipeEdgeMode: String, CaseIterable {
    case trailing
    case leading
    
    static let storageKey = "today.swipeEdgeMode"
    
    var displayName: String {
        switch self {
        case .trailing: return "Left"
        case .leading:  return "Right"
        }
    }
}

