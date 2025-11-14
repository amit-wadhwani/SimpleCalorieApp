import SwiftUI

struct AdCardModel: Identifiable {
    let id = UUID()
    let title: String
    let isAd: Bool
}

struct AdCardView: View {
    let model: AdCardModel
    
    static let sampleAds: [AdCardModel] = [
        AdCardModel(title: "Smart Tip: Try adding healthy fats to breakfast for better satiety.", isAd: false),
        AdCardModel(title: "Simple Premium auto-logs your meals and macros.", isAd: true),
        AdCardModel(title: "Smart Tip: High-protein dinners boost next-day energy.", isAd: false),
        AdCardModel(title: "New SimpleCalorie recipes — discover under 200-calorie snacks.", isAd: true)
    ]

    var body: some View {
        HStack(alignment: .top, spacing: AppSpace.s12) {
            // Blue crescent accent
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.brandPrimary)
                .frame(width: 4)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: AppSpace.sm) {
                HStack(spacing: AppSpace.sm) {
                    Text("AD")
                        .font(AppFont.labelCapsSm(11))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppColor.brandPrimary.opacity(0.1))
                        )
                        .foregroundStyle(AppColor.brandPrimary)

                    Text(model.title)
                        .font(AppFont.bodySm(13))
                        .foregroundStyle(AppColor.textTitle)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .shadow(color: AppColor.borderSubtle.opacity(0.4), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: AppSpace.s12) {
        ForEach(AdCardView.sampleAds) { ad in
            AdCardView(model: ad)
        }
    }
    .background(AppColor.bgScreen)
}

