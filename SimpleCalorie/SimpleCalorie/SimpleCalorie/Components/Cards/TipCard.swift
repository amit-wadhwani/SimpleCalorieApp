import SwiftUI

struct TipCard: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpace.md) {
            Text(emoji)
                .font(.system(size: 18))
                .padding(AppSpace.sm)
                .background(AppColor.brandPrimary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(text)
                .font(AppFont.bodySmSmall())
                .foregroundStyle(AppColor.textTitle)
            Spacer()
        }
        .padding(AppSpace.lg)
        .background(AppColor.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .stroke(AppColor.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
    }
}

#Preview {
    TipCard(emoji: "💡", text: "If you ate like this every day... You'd lose 1.2 lbs/week")
        .padding()
}

