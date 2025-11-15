import SwiftUI

struct AdCardModel: Identifiable {
    let id = UUID()
    let title: String
    let isAd: Bool
}

struct AdBadge: View {
    var body: some View {
        Text("AD")
            .font(AppFont.bodySm(11))
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .foregroundStyle(AppColor.textMuted)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(AppColor.bgScreen)
            )
    }
}

struct AdCardView: View {
    let model: AdCardModel

    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: AppSpace.s12) {
                AdBadge()

                Text(model.title)
                    .font(AppFont.bodySm(14))          // same size as Motivation main text
                    .foregroundStyle(AppColor.textTitle)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Sample data for previews

extension AdCardView {
    static let sampleAds: [AdCardModel] = [
        AdCardModel(
            title: "Smart Tip: Try adding healthy fats to breakfast for better satiety.",
            isAd: true
        ),
        AdCardModel(
            title: "Smart Tip: High-protein dinners boost next-day energy.",
            isAd: true
        ),
        AdCardModel(
            title: "Smart Tip: New under-200-calorie snacks to keep you on track.",
            isAd: true
        )
    ]
}

#Preview {
    VStack(spacing: AppSpace.s12) {
        ForEach(AdCardView.sampleAds) { ad in
            AdCardView(model: ad)
        }
    }
    .padding()
    .background(AppColor.bgScreen)
}
