import SwiftUI

struct CardContainer<Content: View>: View {
    @ViewBuilder private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background with shadow (not clipped)
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(AppColor.bgCard)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 2)

            // Border stroke
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .stroke(AppColor.borderSubtle, lineWidth: 1)

            // Content layer (clipped so nothing spills)
            VStack {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.vertical, AppSpace.s16)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        }
    }
}

