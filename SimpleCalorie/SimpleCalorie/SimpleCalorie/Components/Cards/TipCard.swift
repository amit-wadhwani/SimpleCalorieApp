import SwiftUI

struct TipCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpace.sm) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 16))
                .foregroundStyle(AppColor.brandPrimary)
                .frame(width: 24, height: 24)

            Text(text)
                .font(AppFont.bodySm())
                .foregroundStyle(AppColor.textMuted)
            
            Spacer(minLength: 0)
        }
        .padding(AppSpace.s12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 1)
        )
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    TipCard(text: "If you ate like this every day... You'd lose 1.2 lbs/week")
        .background(AppColor.bgScreen)
}

