import SwiftUI

struct DecorSpacerCard: View {
    @Environment(\.colorScheme) private var colorScheme
    
    // Persisted style choices (set from the debug picker in TodayRootView)
    @AppStorage(TodayLayout.decorStyleKey)
    private var styleRaw: String = TodayLayout.DecorSpacerStyle.capsuleNewTuned.rawValue
    
    @AppStorage(TodayLayout.decorVariantKey)
    private var variantRaw: String = TodayLayout.DecorSpacerVariant.oneLine.rawValue
    
    @AppStorage(TodayLayout.decorAlignKey)
    private var alignRaw: String = TodayLayout.DecorSpacerAlign.center.rawValue
    
    private var style: TodayLayout.DecorSpacerStyle {
        TodayLayout.DecorSpacerStyle(rawValue: styleRaw) ?? .capsuleNewTuned
    }
    
    private var variant: TodayLayout.DecorSpacerVariant {
        TodayLayout.DecorSpacerVariant(rawValue: variantRaw) ?? .oneLine
    }
    
    private var align: TodayLayout.DecorSpacerAlign {
        TodayLayout.DecorSpacerAlign(rawValue: alignRaw) ?? .center
    }
    
    var body: some View {
        Group {
            switch style {
            case .plain:
                plainSpacer
            case .divider:
                dividerSpacer
            case .capsule:
                legacyCapsuleSpacer
            case .capsuleNewTuned:
                tunedCapsuleSpacer
            }
        }
        // Transparent list row so no white strip shows up
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Variants
    
    /// Style: Invisible – just breathing room between cards
    private var plainSpacer: some View {
        Color.clear
            .frame(height: TodayLayout.decorSpacerHeightPlain)
    }
    
    /// Style: Divider – subtle hairline centered under the card gutter
    private var dividerSpacer: some View {
        HStack {
            // Match the card's horizontal inset so the divider aligns with card edges
            Spacer()
                .frame(width: TodayLayout.v1CardInsetH)
            Rectangle()
                .fill(AppColor.borderSubtle) // no extra opacity so it's clearly visible
                .frame(height: 1)            // 1pt hairline
            Spacer()
                .frame(width: TodayLayout.v1CardInsetH)
        }
        .frame(height: TodayLayout.decorSpacerHeightDivider)
    }
    
    /// Style: Old Capsule – same size as new capsule, slightly bolder
    private var legacyCapsuleSpacer: some View {
        HStack {
            switch align {
            case .leading:
                // Capsule hugs the left card edge (respecting the card inset)
                Spacer()
                    .frame(width: TodayLayout.v1CardInsetH)
                legacyCapsuleShape
                Spacer()
            case .center:
                Spacer()
                legacyCapsuleShape
                Spacer()
            }
        }
        .frame(
            height: variant == .oneLine
            ? TodayLayout.decorSpacerHeightCapsuleOne
            : TodayLayout.decorSpacerHeightCapsuleTwo
        )
    }
    
    /// Old capsule's visual: match newCapsule size but a touch darker
    private var legacyCapsuleShape: some View {
        Capsule()
            .fill(
                AppColor.borderSubtle.opacity(
                    colorScheme == .dark
                    ? TodayLayout.newCapsuleOpacityDark + 0.10   // ≈ 0.38
                    : TodayLayout.newCapsuleOpacityLight + 0.10  // ≈ 0.32
                )
            )
            .frame(
                width: TodayLayout.newCapsuleDefaultW,
                height: TodayLayout.newCapsuleDefaultH
            )
    }
    
    /// Style: New Capsule (tuned) – current preferred look
    private var tunedCapsuleSpacer: some View {
        HStack {
            Spacer()
            Capsule()
                .fill(
                    AppColor.borderSubtle.opacity(
                        colorScheme == .dark
                        ? TodayLayout.newCapsuleOpacityDark
                        : TodayLayout.newCapsuleOpacityLight
                    )
                )
                .frame(
                    width: TodayLayout.newCapsuleDefaultW,
                    height: TodayLayout.newCapsuleDefaultH
                )
            Spacer()
        }
        .padding(.vertical, TodayLayout.newCapsuleVPad)
    }
}

#if DEBUG
struct DecorSpacerCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColor.bgScreen.ignoresSafeArea()
            List {
                DecorSpacerCard()
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
