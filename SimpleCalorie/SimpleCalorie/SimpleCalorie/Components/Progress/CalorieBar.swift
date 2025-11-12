import SwiftUI

struct CalorieBar: View {
    let summary: CalorieSummary

    private var progress: CGFloat {
        guard summary.target > 0 else { return 0 }
        return CGFloat(min(max(Double(summary.consumed) / Double(summary.target), 0), 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpace.sm) {
                Text("\(summary.consumed)")
                    .font(AppFont.value())
                    .foregroundStyle(AppColor.textTitle)
                Text("/ \(summary.target) kcal")
                    .font(AppFont.bodySmSmall())
                    .foregroundStyle(AppColor.textMuted)
                Spacer()
            }

            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.black.opacity(0.06))
                    .frame(height: 10)

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColor.brandPrimary)
                        .frame(width: geo.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
            
            Text("Calories remaining: \(max(0, summary.target - summary.consumed))")
                .font(AppFont.bodySmSmall())
                .foregroundStyle(AppColor.textMuted)
        }
    }
}

#Preview {
    CalorieBar(summary: CalorieSummary(consumed: 1320, target: 1800))
        .padding()
}

