import SwiftUI

struct MotivationCardView: View {
    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: AppSpace.s12) {
                // Left icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppColor.brandPrimary.opacity(0.08))
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.brandPrimary)
                }
                .frame(width: 28, height: 28)
                .alignmentGuide(.top) { d in d[.top] }

                // Texts
                VStack(alignment: .leading, spacing: 6) {
                    Text("If you ate like this every day... You'd lose 1.2 lbs/week")
                        .font(AppFont.bodySm(14))
                        .foregroundStyle(AppColor.textTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)

                    Text("Based on your current calorie target.")
                        .font(AppFont.bodySm(12))
                        .foregroundStyle(AppColor.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
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
