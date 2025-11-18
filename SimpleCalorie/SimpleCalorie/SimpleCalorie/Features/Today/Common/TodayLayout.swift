import SwiftUI

enum TodayLayout {
    // V1-locked paddings (do not change without screenshot check)
    static let v1CardInsetH: CGFloat = AppSpace.s12
    static let v1AdTopBottom: CGFloat = AppSpace.s12
    
    // MARK: - Meal card fidelity (V1 locked)
    // Header breathing (V1-locked; tiny lift tonight)
    static let mealHeaderTopPad: CGFloat = 12   // was 10
    static let mealHeaderBottomPad: CGFloat = 10 // was 8
    // Meal header sizing
    static let mealHeaderTitleFont: Font = .system(size: 15, weight: .semibold)
    static let mealHeaderKcalFont: Font = .system(size: 14, weight: .semibold)
    // Card inner padding
    static let mealCardInnerTopPad: CGFloat = AppSpace.xs  // 6pt
    static let mealHPad: CGFloat = AppSpace.s12                                   // ensure left/right breathing
    static let mealRowVPad: CGFloat = 10                  // per-row vertical padding
    static let addRowFont: Font = .system(size: 16, weight: .semibold)
    static let addRowTopPadWhenItemsExist: CGFloat = 8
    static let addRowBottomPad: CGFloat = 2              // tighter than before
    // Card chrome tweaks (lets us trim bottom breathing)
    static let mealCardInnerBottomPad: CGFloat = AppSpace.sm // 8pt
    
    // MARK: - No-ads spacer styles
    enum DecorSpacerStyle: String, CaseIterable {
        case plain, divider, capsule
    }
    
    enum DecorSpacerVariant: String, CaseIterable {
        case oneLine, twoLine
    }
    
    enum DecorSpacerAlign: String, CaseIterable {
        case leading, center
    }
    
    // AppStorage keys (unchanged names; values may be "plain", "divider", "capsule")
    static let decorStyleKey = "today.decor.style"
    static let decorVariantKey = "today.decor.variant" // "oneLine" or "twoLine"
    static let decorAlignKey = "today.decor.align"
    
    // Heights
    static let decorSpacerHeightPlain: CGFloat = 40  // invisible line height
    static let decorSpacerHeightDivider: CGFloat = 24  // short row for hairline divider
    static let decorSpacerHeightCapsuleOne: CGFloat = 36
    static let decorSpacerHeightCapsuleTwo: CGFloat = 56
    
    // Legacy aliases for backward compatibility (will be removed)
    static var gutterH: CGFloat { v1CardInsetH }
    static var adGapAbove: CGFloat { v1AdTopBottom }
    static var adGapBelow: CGFloat { v1AdTopBottom }
    static let cardPadV: CGFloat = AppSpace.s12  // 12pt
}

