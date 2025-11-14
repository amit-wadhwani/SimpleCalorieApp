import SwiftUI

struct MotivationCardView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Chart icon
            ZStack {
                Circle()
                    .fill(AppColor.brandPrimary.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: "chart.line.downtrend.xyaxis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColor.brandPrimary)
            }

            Text("If you ate like this every day... You'd lose 1.2 lbs/week")
                .font(AppFont.bodySm(13))
                .foregroundStyle(AppColor.textTitle)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColor.bgCard)
                .shadow(color: AppColor.borderSubtle.opacity(0.3), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    MotivationCardView()
        .background(AppColor.bgScreen)
}

