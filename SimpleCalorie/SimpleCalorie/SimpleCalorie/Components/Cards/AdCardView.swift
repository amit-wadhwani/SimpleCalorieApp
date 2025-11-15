import SwiftUI

struct AdCardModel: Identifiable {
    let id = UUID()
    let title: String
    let isAd: Bool
}

struct AdBadge: View {
    var body: some View {
        Text("AD")
            .font(AppFont.bodySm(13))
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(AppColor.borderSubtle.opacity(0.3))
            )
            .foregroundStyle(AppColor.textMuted)
    }
}

struct AdCardView: View {
    let model: AdCardModel
    
    static let sampleAds: [AdCardModel] = [
        AdCardModel(title: "Smart Tip: Try adding healthy fats to breakfast for better satiety.", isAd: false),
        AdCardModel(title: "Simple Premium auto-logs your meals and macros.", isAd: true),
        AdCardModel(title: "Smart Tip: High-protein dinners boost next-day energy.", isAd: false)
    ]

    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: AppSpace.s12) {
                AdBadge()
                    .padding(.top, 2)

                Text(model.title)
                    .font(AppFont.bodySm(14))
                    .foregroundStyle(AppColor.textTitle)
                    .lineLimit(2)

                Spacer()
            }
        }
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

