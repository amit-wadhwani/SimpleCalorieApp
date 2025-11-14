import SwiftUI

struct MealSectionView: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddFoodTap: () -> Void
    var onDelete: ((FoodItem) -> Void)?

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
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            VStack(spacing: 0) {
                if items.isEmpty {
                    Text("No items yet. Tap \"Add Food\" to log this meal.")
                        .font(AppFont.bodySm(12))
                        .foregroundStyle(AppColor.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                } else {
                    ForEach(items) { item in
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(AppColor.textTitle)
                                
                                if !item.description.isEmpty && item.description != item.name {
                                    Text(item.description)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(AppColor.textMuted)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(item.calories) kcal")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(AppColor.textMuted)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                onDelete?(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }

                        if item.id != items.last?.id {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }

                Button(action: onAddFoodTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColor.brandPrimary)
                        Text("Add Food")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColor.brandPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppColor.bgCard)
        .cornerRadius(AppRadius.card)
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
                FoodItem(name: "Oatmeal with berries", calories: 245, description: "100g", protein: 8.0, carbs: 45.0, fat: 5.0),
                FoodItem(name: "Black coffee", calories: 0, description: "1 cup", protein: 0, carbs: 0, fat: 0)
            ],
            onAddFoodTap: {}
        )
    }
    .background(AppColor.bgScreen)
}

