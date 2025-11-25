import SwiftUI

private let emeraldColor = Color(red: 52/255, green: 211/255, blue: 153/255)   // #34D399
private let indigoColor  = Color(red: 129/255, green: 140/255, blue: 248/255) // #818CF8
private let skyColor     = Color(red: 56/255, green: 189/255, blue: 248/255)  // #38BDF8
private let amberColor   = Color(red: 251/255, green: 191/255, blue: 36/255)  // #FBBF24

struct MealSectionList: View {
    let meal: MealType
    let items: [FoodItem]
    var onAddTap: ((MealType) -> Void)?
    var onDelete: (FoodItem) -> Void
    @ObservedObject var viewModel: TodayViewModel
    
    @AppStorage(TodayQuickAddMode.storageKey)
    private var quickAddModeRaw: String = TodayQuickAddMode.suggestions.rawValue
    
    private var quickAddMode: TodayQuickAddMode {
        TodayQuickAddMode(rawValue: quickAddModeRaw) ?? .suggestions
    }
    
    @AppStorage(TodaySuggestionsLayoutMode.storageKey)
    private var suggestionsLayoutRaw: String = TodaySuggestionsLayoutMode.horizontal.rawValue
    
    private var suggestionsLayoutMode: TodaySuggestionsLayoutMode {
        TodaySuggestionsLayoutMode(rawValue: suggestionsLayoutRaw) ?? .horizontal
    }
    
    @AppStorage(TodaySwipeEdgeMode.storageKey)
    private var swipeEdgeRaw: String = TodaySwipeEdgeMode.trailing.rawValue
    
    private var swipeEdgeMode: TodaySwipeEdgeMode {
        TodaySwipeEdgeMode(rawValue: swipeEdgeRaw) ?? .trailing
    }
    
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
            if let kind = mealKind,
               items.isEmpty,
               (quickAddMode == .suggestions || quickAddMode == .both) {
                
                VStack(alignment: .leading, spacing: 0) {
                    SmartSuggestionsRow(
                        mealKind: kind,
                        layoutMode: suggestionsLayoutMode,
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
                let swipeDirectionText = swipeEdgeMode == .leading ? "right" : "left"
                
                Text("No items yet. Swipe \(swipeDirectionText) or tap \"Add Food\" to log this meal.")
                    .font(AppFont.bodySm(13))
                    .foregroundStyle(AppColor.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, AppSpace.sm)
                    .padding(.horizontal, TodayLayout.mealHPad)
                    .cardRowBackground(.middle)
                    .accessibilityIdentifier("\(meal.title)EmptyState")
                    .swipeActions(edge: swipeEdgeMode == .leading ? .leading : .trailing,
                                  allowsFullSwipe: false) {
                        if let kind = mealKind,
                           (quickAddMode == .swipe || quickAddMode == .both) {
                            swipeActionsForMeal(kind)
                        }
                    }
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
    
    // MARK: - Swipe Actions (icon-only tiles)
    
    private func swipeActionsForMeal(_ kind: SmartSuggestionsRow.MealKind) -> some View {
        Group {
            switch kind {
            case .breakfast:
                Button {
                    viewModel.handleMealSuggestion(.yesterdayBreakfast)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(emeraldColor)
                .accessibilityIdentifier("swipeYesterday-breakfast")

                Button {
                    viewModel.handleMealSuggestion(.lastWeekBreakfast)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(indigoColor)
                .accessibilityIdentifier("swipeLastWeek-breakfast")

                Button {
                    viewModel.handleMealSuggestion(.copyFromDateBreakfast)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(amberColor)
                .accessibilityIdentifier("swipeChoose-breakfast")

            case .lunch:
                Button {
                    viewModel.handleMealSuggestion(.lastNightDinner)
                } label: {
                    Image(systemName: "moon.stars")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(skyColor)
                .accessibilityIdentifier("swipeLastNight-lunch")

                Button {
                    viewModel.handleMealSuggestion(.yesterdayLunch)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(emeraldColor)
                .accessibilityIdentifier("swipeYesterday-lunch")

                Button {
                    viewModel.handleMealSuggestion(.copyFromDateLunch)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(amberColor)
                .accessibilityIdentifier("swipeChoose-lunch")

            case .dinner:
                Button {
                    viewModel.handleMealSuggestion(.yesterdayDinner)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(emeraldColor)
                .accessibilityIdentifier("swipeYesterday-dinner")

                Button {
                    viewModel.handleMealSuggestion(.lastWeekDinner)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(indigoColor)
                .accessibilityIdentifier("swipeLastWeek-dinner")

                Button {
                    viewModel.handleMealSuggestion(.copyFromDateDinner)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(amberColor)
                .accessibilityIdentifier("swipeChoose-dinner")

            case .snacks:
                Button {
                    viewModel.handleMealSuggestion(.yesterdaySnacks)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(emeraldColor)
                .accessibilityIdentifier("swipeYesterday-snacks")

                Button {
                    viewModel.handleMealSuggestion(.lastWeekSnacks)
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(indigoColor)
                .accessibilityIdentifier("swipeLastWeek-snacks")

                Button {
                    viewModel.handleMealSuggestion(.copyFromDateSnacks)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                }
                .tint(amberColor)
                .accessibilityIdentifier("swipeChoose-snacks")
            }
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
