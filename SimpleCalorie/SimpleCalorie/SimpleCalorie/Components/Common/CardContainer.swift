import SwiftUI

struct CardContainer<Content: View>: View {
    @ViewBuilder private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
            .fill(AppColor.bgCard)
            .shadow(
                color: Color.black.opacity(0.06),
                radius: 14,
                x: 0,
                y: 6
            )
            .overlay(
                content
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.vertical, AppSpace.s12)
            )
    }
}

