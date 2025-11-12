import SwiftUI

struct MealSectionCard: View {
    let meal: MealType
    let items: [FoodEntry]
    let onAdd: () -> Void
    
    private var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: AppSpace.md) {
                HStack {
                    Text(meal.rawValue)
                        .font(AppFont.section())
                        .foregroundStyle(AppColor.textTitle)
                    Spacer()
                    if totalCalories > 0 {
                        Text("\(totalCalories) kcal")
                            .font(AppFont.bodySmSmall())
                            .foregroundStyle(AppColor.textMuted)
                    }
                }

                if items.isEmpty {
                    Text("No items yet")
                        .font(AppFont.bodySmSmall())
                        .foregroundStyle(AppColor.textMuted)
                } else {
                    VStack(alignment: .leading, spacing: AppSpace.sm) {
                        ForEach(items) { item in
                            HStack {
                                Text(item.name)
                                    .font(AppFont.bodySmSmall())
                                    .foregroundStyle(AppColor.textTitle)
                                Spacer()
                                // Removed chevron - no navigation destination
                            }
                        }
                    }
                }

                Button(action: onAdd) {
                    Text("+ Add Food")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.brandPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, AppSpace.s12)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: AppSpace.xl) {
        MealSectionCard(
            meal: .breakfast,
            items: [
                FoodEntry(name: "Oatmeal with berries", calories: 240),
                FoodEntry(name: "Black coffee", calories: 5)
            ],
            onAdd: {}
        )
        MealSectionCard(
            meal: .snacks,
            items: [],
            onAdd: {}
        )
    }
    .padding()
}

