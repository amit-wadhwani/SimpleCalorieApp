import SwiftUI

struct CalorieSegmentsBar: View {
    let segments: Int
    let consumed: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<segments, id: \.self) { index in
                Capsule()
                    .fill(index < consumed
                          ? AppColor.brandPrimary
                          : AppColor.borderSubtle)
                    .frame(height: 8)
            }
        }
    }
}

struct CaloriesBlock: View {
    var consumed: Int
    var goal: Int

    private var remaining: Int { max(goal - consumed, 0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.xs) {
                Text("\(consumed)")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Text("/ \(goal) kcal")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColor.textMuted)
            }

            CalorieSegmentsBar(
                segments: 12,
                consumed: max(0, min(12, Int(round(Double(consumed) / Double(goal) * 12.0))))
            )

            Text("Calories remaining: \(remaining)")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.textMuted)
        }
        .padding(.vertical, AppSpace.s16)
        .padding(.horizontal, AppSpace.s16)
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
    CaloriesBlock(consumed: 1320, goal: 1800)
        .background(AppColor.bgScreen)
}

