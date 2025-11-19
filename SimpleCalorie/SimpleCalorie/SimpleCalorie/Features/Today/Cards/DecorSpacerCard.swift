import SwiftUI

struct DecorSpacerCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        capsuleSeparator
        // Transparent list row so no white strip shows up
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - Spacer

    /// Style: Old Capsule – same size as new capsule, slightly bolder
    private var capsuleSeparator: some View {
        HStack {
            Spacer()
            capsuleSeparatorShape
            Spacer()
        }
        .frame(height: TodayLayout.decorSpacerHeightCapsuleOne)
    }

    /// Old capsule's visual: match newCapsule size but a touch darker
    private var capsuleSeparatorShape: some View {
        Capsule()
            .fill(
                AppColor.borderSubtle.opacity(
                    colorScheme == .dark
                    ? TodayLayout.newCapsuleOpacityDark + 0.10   // ≈ 0.38
                    : TodayLayout.newCapsuleOpacityLight + 0.10  // ≈ 0.32
                )
            )
            .frame(width: TodayLayout.newCapsuleDefaultW,
                   height: TodayLayout.newCapsuleDefaultH)
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
