import SwiftUI

struct DecorSpacerCard: View {
    @AppStorage(TodayLayout.decorStyleKey) private var styleRaw: String = TodayLayout.DecorSpacerStyle.plain.rawValue
    @AppStorage(TodayLayout.decorVariantKey) private var variantRaw: String = TodayLayout.DecorSpacerVariant.oneLine.rawValue
    @AppStorage(TodayLayout.decorAlignKey) private var alignRaw: String = TodayLayout.DecorSpacerAlign.leading.rawValue
    
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
                // centered handle (subtle, classy)
                Capsule()
                    .fill(AppColor.borderSubtle)
                    .frame(width: 72, height: 6)
                    .opacity(0.9)
                    // center vs left inside the card's content width
                    .frame(maxWidth: .infinity,
                           alignment: (align == .center ? .center : .leading))
                    .padding(.horizontal, TodayLayout.v1CardInsetH)
            }
        }
        .frame(height: rowHeight)
        .accessibilityHidden(true)
    }
}

#Preview {
    DecorSpacerCard()
}

