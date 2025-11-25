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

enum TodayCollapsedMacrosStyle: String, CaseIterable {
    // Capsules
    case capsule
    case capsuleWithGoals
    case capsuleWithGoalsAndProgress
    case capsuleProgressHighContrast
    case capsuleProgressGradient
    
    // Badges
    case badgeFill
    case badgeFillBold
    case badgeFillBoldNoUnits
    case badgeFillWithProgress
    case badgeLeftAccent
    
    // Lines
    case verticalLines
    case horizontalLines
    
    static let storageKey = "today.collapsedMacrosStyle"
    
    var displayName: String {
        switch self {
        case .capsule:                       return "Capsule"
        case .capsuleWithGoals:              return "Capsule + Goals"
        case .capsuleWithGoalsAndProgress:   return "Capsule + Progress"
        case .capsuleProgressHighContrast:   return "Capsule HC"
        case .capsuleProgressGradient:       return "Capsule Gradient"
        
        case .badgeFill:                     return "Badge Fill"
        case .badgeFillBold:                 return "Badge Bold"
        case .badgeFillBoldNoUnits:          return "Badge No Units"
        case .badgeFillWithProgress:         return "Badge + Progress"
        case .badgeLeftAccent:               return "Badge Left Accent"
        
        case .verticalLines:                 return "Vertical Lines"
        case .horizontalLines:               return "Horizontal Lines"
        }
    }
}

