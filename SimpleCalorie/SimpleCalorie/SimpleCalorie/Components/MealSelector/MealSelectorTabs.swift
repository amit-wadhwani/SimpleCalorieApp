import SwiftUI

struct MealTabsView: View {
    @Binding var selectedMeal: MealType

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MealType.allCases) { meal in
                    Button {
                        selectedMeal = meal
                    } label: {
                        Text(meal.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(
                                selectedMeal == meal
                                ? AppColor.textTitle
                                : AppColor.textMuted
                            )
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(
                                selectedMeal == meal
                                ? AppColor.bgCard
                                : Color.clear
                            )
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: MealType = .breakfast
        var body: some View {
            MealTabsView(selectedMeal: $selected)
                .background(AppColor.bgScreen)
        }
    }
    return PreviewWrapper()
}

