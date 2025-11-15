import SwiftUI

struct MealSectionList: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddTap: () -> Void
    var onDelete: (FoodItem) -> Void

    // MARK: - Body
    var body: some View {
        Group {
            // 1) Header row (e.g., "Breakfast" + total kcal)
            headerRowWithDivider

            if items.isEmpty {
                // 2) Placeholder row (when empty)
                emptyPlaceholderRow
                    .cardRowBackground(.middle)
                    .listRowSeparator(.hidden)
            } else {
                // 2) Item rows (each swipable)
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    MealItemRowWithDivider(
                        item: item,
                        isLastItem: index == items.count - 1
                    )
                    .cardRowBackground(.middle) // All item rows are middle; "Add Food" is bottom
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDelete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            // 3) + Add Food row (always last)
            addFoodRowWithDivider
            
            // 4) Spacer after card
            SpacerRow(height: 8)
        }
    }

    // MARK: - Rows

    private var headerRowWithDivider: some View {
        HStack {
            Text(meal.title)
                .font(.system(size: 15, weight: .semibold)) // same as current header
                .foregroundStyle(AppColor.textTitle)
            Spacer()
            if totalCalories > 0 {
                Text("\(totalCalories) kcal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.horizontal, 12)
                .foregroundStyle(AppColor.borderSubtle)
        }
        .cardRowBackground(.top)
        .listRowSeparator(.hidden)
    }

    private var emptyPlaceholderRow: some View {
        Text("No items yet. Tap \"Add Food\" to log this meal.")
            .font(AppFont.bodySm(13))
            .foregroundStyle(AppColor.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }

    private var addFoodRowWithDivider: some View {
        Button(action: onAddTap) {
            Text("+ Add Food")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.brandPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .accessibilityLabel("Add Food to \(meal.title)")
        .overlay(alignment: .top) {
            Divider()
                .padding(.horizontal, 12)
                .foregroundStyle(AppColor.borderSubtle)
        }
        .cardRowBackground(.bottom)
        .listRowSeparator(.hidden)
    }

    private var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
}

private struct MealItemRowWithDivider: View {
    let item: FoodItem
    let isLastItem: Bool
    
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
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            if !isLastItem {
                Divider()
                    .padding(.horizontal, 12)
                    .foregroundStyle(AppColor.borderSubtle)
            }
        }
    }
}

