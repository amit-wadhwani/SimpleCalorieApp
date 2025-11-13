import SwiftUI

struct TodayHeaderView: View {
    @Binding var selectedDate: Date
    let consumedCalories: Double
    let dailyGoalCalories: Double
    var onDateTap: () -> Void
    var onSettingsTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.s16) {
            // Top row - no title, just settings
            HStack {
                // Placeholder for future brand icon
                Spacer().frame(width: 24, height: 24)

                Spacer()

                Button {
                    onSettingsTap?()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.textTitle)
                }
            }

            // Date row - tappable
            Button(action: onDateTap) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .medium))
                    Text(formattedDate())
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(AppColor.textMuted)
                .frame(maxWidth: .infinity)
            }

            // Calorie summary card
            CalorieSummaryCard(
                consumed: consumedCalories,
                goal: dailyGoalCalories
            )

            // Macros section
            MacrosSectionView()
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.s16)
        .padding(.bottom, 8)
        .background(AppColor.bgScreen)
    }
    
    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: selectedDate)
    }
}

#Preview {
    TodayHeaderView(
        selectedDate: .constant(Date()),
        consumedCalories: 1320,
        dailyGoalCalories: 1800,
        onDateTap: {}
    )
    .background(AppColor.bgScreen)
}

