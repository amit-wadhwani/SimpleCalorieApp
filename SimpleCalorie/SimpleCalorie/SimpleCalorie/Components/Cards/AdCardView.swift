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
        HStack(alignment: .center, spacing: 12) {
            // Left C-shaped vertical bar with rounded ends
            VStack {
                RoundedRectangle(cornerRadius: 999)
                    .fill(AppColor.brandPrimary)
                    .frame(width: 4, height: 40)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("AD")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColor.bgScreen)
                        )
                        .foregroundStyle(AppColor.textMuted)

                    Text(model.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColor.textTitle)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, AppSpace.s16)
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

