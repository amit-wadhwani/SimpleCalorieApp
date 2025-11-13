import SwiftUI

struct MealSectionView: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddFoodTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meal.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                if totalCalories > 0 {
                    Text("\(totalCalories) kcal")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColor.textMuted)
            }

            ForEach(items) { item in
                HStack {
                    Text(item.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColor.textMuted)
                }
            }

            Button(action: onAddFoodTap) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColor.brandPrimary)
                    Text("Add Food")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textTitle)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(AppColor.bgCard)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    private var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
}

#Preview {
    VStack(spacing: AppSpace.s12) {
        MealSectionView(
            meal: .breakfast,
            items: [
                FoodItem(name: "Oatmeal with berries", calories: 245, description: "Oatmeal with berries"),
                FoodItem(name: "Black coffee", calories: 0, description: "Black coffee")
            ],
            onAddFoodTap: {}
        )
    }
    .background(AppColor.bgScreen)
}

