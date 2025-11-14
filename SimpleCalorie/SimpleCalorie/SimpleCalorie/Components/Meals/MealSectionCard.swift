import SwiftUI

struct MealSectionCard: View {
    let meal: MealType
    let items: [FoodEntry]
    let onAdd: () -> Void
    
    private var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
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
                HStack(spacing: AppSpace.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Food")
                }
                .font(AppFont.bodySmSmall())
                .foregroundStyle(AppColor.brandPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpace.lg)
        .background(AppColor.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .stroke(AppColor.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
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

