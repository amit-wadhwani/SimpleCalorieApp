import SwiftUI

struct MealSectionList: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddTap: ((MealType) -> Void)?
    var onDelete: (FoodItem) -> Void

    // MARK: - Body
    var body: some View {
        CardRowBackgroundView(
            hPad: TodayLayout.mealHPad,
            topPad: TodayLayout.mealCardInnerTopPad,               // NEW (was 0)
            bottomPad: TodayLayout.mealCardInnerBottomPad
        ) {
            VStack(spacing: 0) {
                // 1) Header row
                headerRow
                
                // Single divider directly under the header
                Divider()
                
                if items.isEmpty {
                    // 2) Placeholder row (when empty)
                    emptyPlaceholderRow
                } else {
                    // 2) Item rows (each swipable) - dividers only between items
                    ForEach(items.indices, id: \.self) { idx in
                        MealItemRow(item: items[idx])
                            .padding(.vertical, TodayLayout.mealRowVPad)
                            .overlay(alignment: .bottom) {
                                if idx < items.count - 1 {
                                    Divider()
                                }
                            }
                            .contentShape(Rectangle()) // generous hit area
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Haptics.rigid()
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        onDelete(items[idx])
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(items[idx].name), \(items[idx].calories) calories")
                            .accessibilityAction(named: "Delete") {
                                onDelete(items[idx])
                            }
                    }
                }

                // 3) + Add Food (correct size and tighter bottom space)
                Button(action: { onAddTap?(meal) }) {
                    Text("+ Add Food")
                        .font(TodayLayout.addRowFont)
                        .foregroundStyle(AppColor.brandPrimary)
                }
                .padding(.top, items.isEmpty ? 4 : TodayLayout.addRowTopPadWhenItemsExist)
                .padding(.bottom, TodayLayout.addRowBottomPad)
                .accessibilityLabel("Add Food")
                .buttonStyle(.plain)
            }
        }
        .listRowInsets(.init(top: 0, leading: TodayLayout.v1CardInsetH, bottom: 0, trailing: TodayLayout.v1CardInsetH))
        .listRowSeparator(.hidden)
    }

    // MARK: - Rows

    private var headerRow: some View {
        // Header
        HStack(alignment: .firstTextBaseline) {
            Text(meal.title)
                .font(TodayLayout.mealHeaderTitleFont)
                .foregroundStyle(AppColor.textTitle)
            Spacer(minLength: 0)
            Text("\(Double(totalCalories), specifier: "%.0f") kcal")
                .font(TodayLayout.mealHeaderKcalFont)
                .foregroundStyle(AppColor.textTitle)
        }
        .padding(.top, TodayLayout.mealHeaderTopPad)
        .padding(.bottom, TodayLayout.mealHeaderBottomPad)
        .accessibilityHeading(.h2)
    }

    private var emptyPlaceholderRow: some View {
        Text("No items yet. Tap \"Add Food\" to log this meal.")
            .font(AppFont.bodySm(13))
            .foregroundStyle(AppColor.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, AppSpace.sm)
            // No horizontal padding - CardRowBackgroundView provides it
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

