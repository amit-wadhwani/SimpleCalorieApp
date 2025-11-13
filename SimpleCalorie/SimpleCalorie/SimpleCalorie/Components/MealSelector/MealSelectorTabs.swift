import SwiftUI

struct MealSelectorTabs: View {
    @Binding var selectedMeal: MealType

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MealType.allCases) { meal in
                Button(action: { selectedMeal = meal }) {
                    Text(meal.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Group {
                                if meal == selectedMeal {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColor.bgCard)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColor.bgScreen)
                                }
                            }
                        )
                        .foregroundStyle(
                            meal == selectedMeal
                                ? AppColor.brandPrimary
                                : AppColor.textMuted
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: MealType = .breakfast
        var body: some View {
            MealSelectorTabs(selectedMeal: $selected)
                .background(AppColor.bgScreen)
        }
    }
    return PreviewWrapper()
}

