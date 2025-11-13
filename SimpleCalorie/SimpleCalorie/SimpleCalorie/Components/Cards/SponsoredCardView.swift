import SwiftUI

struct SponsoredCardView: View {
    let title: String
    let subtitle: String?
    let emoji: String?

    init(title: String, subtitle: String? = nil, emoji: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.emoji = emoji
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Sponsored")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColor.brandPrimary)

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                }
            }

            Spacer()
        }
        .padding(AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 1)
        )
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    VStack(spacing: AppSpace.s12) {
        SponsoredCardView(
            title: "Simple Premium auto-logs your meals and macros.",
            subtitle: "Upgrade to save time and stay on track.",
            emoji: "🍓"
        )
        SponsoredCardView(
            title: "New recipes under 300 calories.",
            subtitle: "Discover simple, satisfying meals.",
            emoji: "🍩"
        )
    }
    .background(AppColor.bgScreen)
}

