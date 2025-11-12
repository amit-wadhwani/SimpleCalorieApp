import SwiftUI

struct TipCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColor.bgScreen.opacity(0.8))
                    .frame(width: 32, height: 32)

                Image(systemName: "chart.line.downtrend.xyaxis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColor.brandPrimary)
            }

            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.textTitle)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, AppSpace.s12)
        .padding(.horizontal, AppSpace.s16)
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

