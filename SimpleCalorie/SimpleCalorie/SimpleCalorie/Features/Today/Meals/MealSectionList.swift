import SwiftUI

struct MealSectionList: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddTap: ((MealType) -> Void)?
    var onDelete: (FoodItem) -> Void

    var body: some View {
        Group {
            // --- Header --------------------------------------------------------------
            HStack(spacing: 8) {
                Text(meal.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)
                
                Spacer(minLength: 0)
                
                Text("\(totalCalories) kcal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)
            }
            .padding(.top, TodayLayout.mealHeaderTopPad)
            .padding(.bottom, TodayLayout.mealHeaderBottomPad)
            .padding(.horizontal, TodayLayout.mealHPad)
            .overlay(alignment: .bottom) {
                // Header divider: content-width only (from "Breakfast" to "245 kcal")
                Rectangle()
                    .fill(AppColor.borderSubtle)
                    .frame(height: 1)            // full pixel for clearer visibility
                    .opacity(0.35)                // slightly softer while still visible
                    .padding(.horizontal, TodayLayout.mealHPad)
            }
            .cardRowBackground(.top)
            .accessibilityHeading(.h2)
            
            if items.isEmpty {
                // Empty placeholder
                Text("No items yet. Tap \"Add Food\" to log this meal.")
                    .font(AppFont.bodySm(13))
                    .foregroundStyle(AppColor.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, AppSpace.sm)
                    .padding(.horizontal, TodayLayout.mealHPad)
                    .cardRowBackground(.middle)
            } else {
                // MARK: Items
                ForEach(items.indices, id: \.self) { idx in
                    let item = items[idx]
                    let isLast = idx == items.count - 1
                    
                    MealItemRow(item: item)
                        .padding(.vertical, TodayLayout.mealRowVPad)
                        .padding(.horizontal, TodayLayout.mealHPad)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { onDelete(item) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if !isLast {
                                // Inter-item divider: content-width only (under text span)
                                Rectangle()
                                    .fill(AppColor.borderSubtle)
                                    .frame(height: 1)        // full pixel
                                    .opacity(0.25)            // slightly softer while still visible
                                    .padding(.horizontal, TodayLayout.mealHPad)
                            }
                        }
                        .cardRowBackground(.middle)                // bottom chrome belongs to Add row
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.name), \(Int(item.calories)) calories")
                        .accessibilityAction(named: "Delete") {
                            onDelete(item)
                        }
                }
            }
            
            // --- "+ Add Food" (no bottom divider) -----------------------------------
            Button(action: { onAddTap?(meal) }) {
                Text("+ Add Food")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(AppColor.brandPrimary)    // keep your blue
            }
            .buttonStyle(.plain)
            .padding(.top, TodayLayout.addRowTopGap)
            .padding(.bottom, TodayLayout.addRowBottomPad)
            .padding(.horizontal, TodayLayout.mealHPad)
            .cardRowBackground(.bottom)  // bottom chrome, no line under
            .accessibilityLabel("Add Food")
            .accessibilityAddTraits(.isButton)
        }
    }
    
    private var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
}

private struct MealItemRow: View, Equatable {
    let item: FoodItem
    
    static func == (lhs: MealItemRow, rhs: MealItemRow) -> Bool {
        lhs.item.id == rhs.item.id
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColor.textTitle)
                
                if !item.description.isEmpty && item.description != item.name {
                    Text(item.description) // e.g., "1 cup"
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                }
            }
            Spacer()
            Text("\(Int(item.calories)) kcal")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(AppColor.textMuted)
        }
    }
}
