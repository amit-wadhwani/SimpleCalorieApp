import SwiftUI

struct DecorSpacerCard: View {
    @AppStorage(TodayLayout.decorStyleKey) private var styleRaw: String = TodayLayout.DecorSpacerStyle.plain.rawValue
    @AppStorage(TodayLayout.decorVariantKey) private var variantRaw: String = TodayLayout.DecorSpacerVariant.oneLine.rawValue
    @AppStorage(TodayLayout.decorAlignKey) private var alignRaw: String = TodayLayout.DecorSpacerAlign.leading.rawValue
    @Environment(\.colorScheme) private var colorScheme
    
    private var style: TodayLayout.DecorSpacerStyle {
        TodayLayout.DecorSpacerStyle(rawValue: styleRaw) ?? .plain
    }
    
    private var variant: TodayLayout.DecorSpacerVariant {
        TodayLayout.DecorSpacerVariant(rawValue: variantRaw) ?? .oneLine
    }
    
    private var align: TodayLayout.DecorSpacerAlign {
        TodayLayout.DecorSpacerAlign(rawValue: alignRaw) ?? .leading
    }
    
    private var rowHeight: CGFloat {
        switch style {
        case .plain: return TodayLayout.decorSpacerHeightPlain
        case .divider: return TodayLayout.decorSpacerHeightDivider
        case .capsule:
            return (variant == .twoLine)
                ? TodayLayout.decorSpacerHeightCapsuleTwo
                : TodayLayout.decorSpacerHeightCapsuleOne
        case .capsuleNewTuned:
            // Single-line row with vertical padding
            return TodayLayout.newCapsuleDefaultH + (TodayLayout.newCapsuleVPad * 2)
        }
    }
    
    var body: some View {
        ZStack {
            switch style {
            case .plain:
                Color.clear
            case .divider:
                // subtle full-width hairline with card insets handled by listRowInsets
                Rectangle()
                    .fill(AppColor.borderSubtle)
                    .frame(height: 1)
                    .padding(.horizontal, TodayLayout.v1CardInsetH)
                    .opacity(0.9)
            case .capsule:
                // centered handle (subtle, classy) - Old Capsule, unchanged
                Capsule()
                    .fill(AppColor.borderSubtle)
                    .frame(width: 72, height: 6)
                    .opacity(0.9)
                    // center vs left inside the card's content width
                    .frame(maxWidth: .infinity,
                           alignment: (align == .center ? .center : .leading))
                    .padding(.horizontal, TodayLayout.v1CardInsetH)
            case .capsuleNewTuned:
                let w = min(max(TodayLayout.newCapsuleDefaultW, TodayLayout.newCapsuleMinW), TodayLayout.newCapsuleMaxW)
                let h = min(max(TodayLayout.newCapsuleDefaultH, TodayLayout.newCapsuleMinH), TodayLayout.newCapsuleMaxH)
                let opacity = (colorScheme == .dark) ? TodayLayout.newCapsuleOpacityDark : TodayLayout.newCapsuleOpacityLight
                
                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .fill(AppColor.borderSubtle.opacity(opacity))
                    .frame(width: w, height: h)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, TodayLayout.newCapsuleVPad)
            }
        }
        .frame(height: rowHeight)
        .accessibilityHidden(true)
    }
}

#Preview {
    DecorSpacerCard()
}

