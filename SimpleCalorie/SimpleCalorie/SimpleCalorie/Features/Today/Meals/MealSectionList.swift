import SwiftUI

struct MealSectionList: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddTap: ((MealType) -> Void)?
    var onDelete: (FoodItem) -> Void
    @ObservedObject var viewModel: TodayViewModel
    
    
    private var mealKind: SmartSuggestionsRow.MealKind? {
        switch meal {
        case .breakfast: return .breakfast
        case .lunch:     return .lunch
        case .dinner:    return .dinner
        case .snacks:    return .snacks
        }
    }

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
                Rectangle()
                    .fill(AppColor.borderSubtle)
                    .frame(height: 1)
                    .opacity(0.35)
                    .padding(.horizontal, TodayLayout.mealHPad)
            }
            .cardRowBackground(.top)
            .accessibilityHeading(.h2)
            .accessibilityIdentifier("\(meal.title)Header")
            
            // --- Smart Suggestions Row (only when meal is empty) --------------------
            if let kind = mealKind, items.isEmpty {
                
                VStack(alignment: .leading, spacing: 0) {
                    SmartSuggestionsRow(
                        mealKind: kind,
                        layoutMode: .vertical,
                        hasYesterday: hasYesterdayAvailability(for: kind),
                        hasLastWeekOrNight: hasLastWeekOrNightAvailability(for: kind),
                        hasTodayLunch: (kind == .dinner) ? viewModel.hasTodayLunchForDinner : false,
                        onYesterdayTapped: {
                            handleYesterdaySuggestion(for: kind)
                        },
                        onLastWeekOrLastNightTapped: {
                            handleLastWeekOrNightSuggestion(for: kind)
                        },
                        onTodayLunchTapped: {
                            if kind == .dinner {
                                viewModel.handleTodayLunchToDinner()
                            }
                        },
                        onCopyFromDateTapped: {
                            viewModel.presentCopyFromDatePicker(for: kind)
                        }
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .padding(.horizontal, TodayLayout.mealHPad)
                    
                    Divider()
                        .opacity(0.1)
                        .padding(.horizontal, TodayLayout.mealHPad)
                }
                .cardRowBackground(.middle)
            }
            
            // --- Empty state vs items ----------------------------------------------
            if items.isEmpty {
                Text("No items yet. Tap \"Add Food\" to log this meal.")
                    .font(AppFont.bodySm(13))
                    .foregroundStyle(AppColor.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, AppSpace.sm)
                    .padding(.horizontal, TodayLayout.mealHPad)
                    .cardRowBackground(.middle)
                    .accessibilityIdentifier("\(meal.title)EmptyState")
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
                            Button(role: .destructive) {
                                onDelete(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if !isLast {
                                Rectangle()
                                    .fill(AppColor.borderSubtle)
                                    .frame(height: 1)
                                    .opacity(0.25)
                                    .padding(.horizontal, TodayLayout.mealHPad)
                            }
                        }
                        .cardRowBackground(.middle)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.name), \(Int(item.calories)) calories")
                        .accessibilityAction(named: "Delete") {
                            onDelete(item)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: items.count)
            }
            
            // --- "+ Add Food" (no bottom divider) -----------------------------------
            Button(action: { onAddTap?(meal) }) {
                Text("+ Add Food")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(AppColor.brandPrimary)
            }
            .buttonStyle(.plain)
            .padding(.top, TodayLayout.addRowTopGap)
            .padding(.bottom, TodayLayout.addRowBottomPad)
            .padding(.horizontal, TodayLayout.mealHPad)
            .cardRowBackground(.bottom)
            .accessibilityLabel("Add Food")
            .accessibilityIdentifier("addFoodButton-\(meal.title)")
            .accessibilityAddTraits(.isButton)
        }
    }
    
    private var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    // MARK: - Quick Add Helpers
    
    private func hasYesterdayAvailability(for kind: SmartSuggestionsRow.MealKind) -> Bool {
        switch kind {
        case .breakfast: return viewModel.hasYesterdayBreakfast
        case .lunch:     return viewModel.hasYesterdayLunch
        case .dinner:    return viewModel.hasYesterdayDinner
        case .snacks:    return viewModel.hasYesterdaySnacks
        }
    }
    
    private func hasLastWeekOrNightAvailability(for kind: SmartSuggestionsRow.MealKind) -> Bool {
        switch kind {
        case .breakfast: return viewModel.hasLastWeekBreakfast
        case .lunch:     return viewModel.hasLastNightDinnerForLunch
        case .dinner:    return viewModel.hasLastWeekDinner
        case .snacks:    return viewModel.hasLastWeekSnacks
        }
    }
    
    private func handleYesterdaySuggestion(for kind: SmartSuggestionsRow.MealKind) {
        switch kind {
        case .breakfast:
            viewModel.handleMealSuggestion(.yesterdayBreakfast)
        case .lunch:
            viewModel.handleMealSuggestion(.yesterdayLunch)
        case .dinner:
            viewModel.handleMealSuggestion(.yesterdayDinner)
        case .snacks:
            viewModel.handleMealSuggestion(.yesterdaySnacks)
        }
    }
    
    private func handleLastWeekOrNightSuggestion(for kind: SmartSuggestionsRow.MealKind) {
        switch kind {
        case .breakfast:
            viewModel.handleMealSuggestion(.lastWeekBreakfast)
        case .lunch:
            viewModel.handleMealSuggestion(.lastNightDinner)
        case .dinner:
            viewModel.handleMealSuggestion(.lastWeekDinner)
        case .snacks:
            viewModel.handleMealSuggestion(.lastWeekSnacks)
        }
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
                    Text(item.description)
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
