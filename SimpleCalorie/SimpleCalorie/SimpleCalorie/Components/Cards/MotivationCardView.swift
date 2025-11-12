import SwiftUI

struct MotivationCardView: View {
    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: AppSpace.s12) {
                // Left icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppColor.brandPrimary.opacity(0.08))
                    // Always show a weight-loss (down) trend for now
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.brandPrimary)
                }
                .frame(width: 28, height: 28)
                .alignmentGuide(.top) { d in d[.top] }

                // Text
                Text("If you ate like this every day... You'd lose 1.2 lbs/week")
                    .font(AppFont.bodySm(14))
                    .foregroundStyle(AppColor.textTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)

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
