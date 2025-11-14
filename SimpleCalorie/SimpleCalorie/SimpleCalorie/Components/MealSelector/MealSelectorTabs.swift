import SwiftUI

struct MealTabsView: View {
    @Binding var selectedMeal: MealType

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MealType.allCases) { meal in
                Button {
                    selectedMeal = meal
                } label: {
                    Text(meal.title)
                        .font(AppFont.bodySm(13))
                        .fontWeight(.semibold)
                        .padding(.horizontal, AppSpace.s12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedMeal == meal
                            ? AppColor.bgCard
                            : Color.clear
                        )
                        .foregroundStyle(
                            selectedMeal == meal
                            ? AppColor.textTitle
                            : AppColor.textMuted
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(AppColor.bgScreen.opacity(0.8))
        .clipShape(Capsule())
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.s12)
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

