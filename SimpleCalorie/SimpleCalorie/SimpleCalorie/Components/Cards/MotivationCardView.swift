import SwiftUI

struct MotivationCardView: View {
    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: AppSpace.s12) {
                // Icon bubble
                ZStack {
                    Circle()
                        .fill(AppColor.brandPrimary.opacity(0.08))
                        .frame(width: 32, height: 32)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.brandPrimary)
                }

                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text("If you ate like this every day... You'd lose 1.2 lbs/week")
                        .font(AppFont.bodySm(14))              // matches Ad card body size
                        .foregroundStyle(AppColor.textTitle)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Based on your current calorie target.")
                        .font(AppFont.bodySm(12))
                        .foregroundStyle(AppColor.textMuted)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    MotivationCardView()
        .padding()
        .background(AppColor.bgScreen)
}
