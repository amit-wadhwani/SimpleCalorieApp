import SwiftUI

struct MotivationCardView: View {
    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: AppSpace.s12) {
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
                    .font(AppFont.bodySm(14))
                    .foregroundStyle(AppColor.textTitle)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MotivationCardView()
        .background(AppColor.bgScreen)
}

