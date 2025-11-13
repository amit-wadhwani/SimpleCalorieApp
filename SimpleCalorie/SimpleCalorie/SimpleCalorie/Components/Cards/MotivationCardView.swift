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
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.textTitle)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppColor.brandPrimary.opacity(0.05))
                )
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    MotivationCardView()
        .background(AppColor.bgScreen)
}

