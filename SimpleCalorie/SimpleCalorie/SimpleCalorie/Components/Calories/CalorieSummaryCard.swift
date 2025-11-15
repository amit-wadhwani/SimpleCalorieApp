import SwiftUI

struct CalorieSummaryCard: View {
    let consumed: Double
    let goal: Double
    private let segments: Int = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(Int(consumed).formatted()) / \(Int(goal).formatted()) kcal")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.textTitle)

            SegmentedCalorieBar(consumed: consumed, goal: goal, segments: segments)

            Text("Calories remaining: \(Int(max(goal - consumed, 0)).formatted())")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppColor.textMuted)
        }
        .padding(16)
        .background(AppColor.bgCard)
        .cornerRadius(AppRadius.card)
        .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

struct SegmentedCalorieBar: View {
    let consumed: Double
    let goal: Double
    let segments: Int

    var body: some View {
        let ratio = goal > 0 ? min(max(consumed / goal, 0), 1) : 0
        let filledSegments = Int(round(ratio * Double(segments)))

        HStack(spacing: 4) {
            ForEach(0..<segments, id: \.self) { index in
                Capsule()
                    .fill(index < filledSegments
                          ? AppColor.textTitle
                          : AppColor.borderSubtle)
                    .frame(height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: consumed)
    }
}

#Preview {
    CalorieSummaryCard(consumed: 1320, goal: 1800)
        .background(AppColor.bgScreen)
}

