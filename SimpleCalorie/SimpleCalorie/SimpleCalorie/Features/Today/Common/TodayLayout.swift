import SwiftUI

enum TodayLayout {
    // Outer card margin so meal & motivation/ad cards align with the top summary card
    static let v1CardInsetH: CGFloat = AppSpace.s16
    
    // Inner content paddings
    static let mealHPad: CGFloat = 12
    static let mealRowVPad: CGFloat = 8
    
    // Header breathing (title + total kcal)
    static let mealHeaderTopPad: CGFloat = 16   // more space from top card edge
    static let mealHeaderBottomPad: CGFloat = 12
    
    // Add row breathing
    static let addRowTopGap: CGFloat = 8
    static let addRowBottomPad: CGFloat = 10
    
    // Card corner
    static let cardCorner: CGFloat = 12
    
    // Typography — keep your existing fonts/colors elsewhere;
    // these are the two we explicitly control in the meal header and Add row.
    static let mealHeaderTitleFont: Font = .system(size: 15, weight: .semibold)
    static let mealHeaderKcalFont: Font = .system(size: 14, weight: .semibold)
    static let addRowFont: Font = .system(size: 16, weight: .semibold)
    
    // Legacy/other tokens
    static let v1AdTopBottom: CGFloat = AppSpace.s12
    
    // MARK: - No-ads spacer (fixed old capsule)
    static let decorSpacerHeightCapsuleOne: CGFloat = 36
    static let newCapsuleDefaultW: CGFloat = 64
    static let newCapsuleDefaultH: CGFloat = 7
    /// opacity range (auto-inverts)
    static let newCapsuleOpacityLight: CGFloat = 0.22
    static let newCapsuleOpacityDark: CGFloat = 0.28
    
    // Legacy aliases for backward compatibility (will be removed)
    static var gutterH: CGFloat { v1CardInsetH }
    static var adGapAbove: CGFloat { v1AdTopBottom }
    static var adGapBelow: CGFloat { v1AdTopBottom }
    static let cardPadV: CGFloat = AppSpace.s12  // 12pt
}

