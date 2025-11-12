import SwiftUI

struct SponsoredCardView: View {
    let title: String
    let isAd: Bool

    init(title: String, isAd: Bool = true) {
        self.title = title
        self.isAd = isAd
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left blue crescent / pill
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColor.brandPrimary.opacity(0.1))
                .frame(width: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.brandPrimary)
                        .frame(width: 3),
                    alignment: .center
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if isAd {
                        Text("AD")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColor.bgScreen)
                            )
                            .foregroundStyle(AppColor.textMuted)
                    }

                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColor.textTitle)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard)
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    VStack(spacing: AppSpace.s12) {
        SponsoredCardView(
            title: "Simple Premium auto-logs your meals and macros.",
            isAd: true
        )
        SponsoredCardView(
            title: "Smart Tip: Try adding healthy fats to breakfast for better satiety.",
            isAd: false
        )
    }
    .background(AppColor.bgScreen)
}

