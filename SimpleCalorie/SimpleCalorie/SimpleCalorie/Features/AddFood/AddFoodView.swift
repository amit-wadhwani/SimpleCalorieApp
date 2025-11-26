import SwiftUI
import UIKit

struct AddFoodView: View {
    @EnvironmentObject var todayViewModel: TodayViewModel
    @StateObject private var searchViewModel: AddFoodViewModel
    @StateObject private var favoritesStore = FavoritesStore()
    @Environment(\.dismiss) private var dismiss
    var onFoodAdded: ((FoodItem, MealType) -> Void)? = nil
    
    @State private var activeMeal: MealType
    @State private var query: String = ""

    init(initialSelectedMeal: MealType, onFoodAdded: ((FoodItem, MealType) -> Void)? = nil) {
        self.onFoodAdded = onFoodAdded
        self._activeMeal = State(initialValue: initialSelectedMeal) // source of truth on open
        let foodSearchService = LocalDemoFoodSearchService()
        let viewModel = AddFoodViewModel(searchService: foodSearchService)
        viewModel.onFoodAdded = onFoodAdded
        // onFoodAddedToDates will be set in onAppear when we have access to todayViewModel
        self._searchViewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.bgScreen
                .ignoresSafeArea()
            
            VStack(spacing: AppSpace.s12) {
                TopBarView(title: "Add Food") {
                    dismiss()
                }
                
                MealTabsView(selectedMeal: $activeMeal)
                
                SearchBarView(placeholder: "Search database...", text: $query)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onChange(of: query) { _, newValue in
                        searchViewModel.query = newValue
                        Task { await searchViewModel.refresh() }
                    }
                    .padding(.horizontal, AppSpace.s16)
                
                ResultsHeaderView(count: searchViewModel.rows.count)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpace.s12) {
                        ForEach(Array(zip(searchViewModel.results, searchViewModel.rows)), id: \.0.id) { food, row in
                            FoodRowView(props: row) {
                                // Quick add: + button tapped
                                searchViewModel.quickAddFood(food, to: activeMeal)
                                Haptics.success()
                                dismiss()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Row tapped: open detail sheet
                                // Note: Button taps will not trigger this gesture
                                searchViewModel.didSelectFood(food)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.bottom, AppSpace.s16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .onAppear {
            // Sync selected date from TodayViewModel
            searchViewModel.selectedDate = todayViewModel.selectedDate
            // Set up multi-date callback
            searchViewModel.onFoodAddedToDates = { dates, item, meal in
                todayViewModel.add(item, to: meal, on: dates)
            }
        }
        .onChange(of: todayViewModel.selectedDate) { _, newDate in
            searchViewModel.selectedDate = newDate
        }
        .sheet(isPresented: $searchViewModel.isShowingDetail) {
            if let selectedFood = searchViewModel.selectedFood {
                FoodDetailSheet(
                    food: selectedFood,
                    state: Binding(
                        get: { 
                            let calendar = Calendar.current
                            let today = calendar.startOfDay(for: Date())
                            return searchViewModel.foodDetailState ?? AddFoodViewModel.FoodDetailState(
                                selectedServing: nil,
                                customAmountInGrams: nil,
                                quantity: 1.0,
                                selectedWeekdays: [],
                                selectedDates: [],
                                isRecurring: false,
                                recurringEndDate: nil,
                                baseDate: today
                            )
                        },
                        set: { searchViewModel.foodDetailState = $0 }
                    ),
                    meal: activeMeal,
                    isFavorite: favoritesStore.isFavorite(selectedFood.id),
                    onServingSizeTap: { option in
                        searchViewModel.selectServingOption(option)
                    },
                    onDefaultServingTap: {
                        searchViewModel.selectDefaultServing()
                    },
                    onCustomServingCommit: { grams in
                        searchViewModel.setCustomAmount(grams > 0 ? grams : nil)
                    },
                    onQuantityChange: { quantity in
                        searchViewModel.setQuantity(quantity)
                    },
                    onWeekdayToggle: { weekday in
                        searchViewModel.toggleWeekday(weekday)
                    },
                    onDateToggle: { date in
                        searchViewModel.toggleDate(date)
                    },
                    onRecurringToggle: {
                        searchViewModel.toggleRecurring()
                    },
                    onAdd: { meal in
                        searchViewModel.confirmAddFromDetail(to: meal)
                        Haptics.success()
                        dismiss()
                    },
                    onCancel: {
                        searchViewModel.isShowingDetail = false
                    },
                    onFavoriteToggle: {
                        favoritesStore.toggleFavorite(selectedFood.id)
                    },
                    onRecurringEndDateChange: { date in
                        searchViewModel.updateRecurringEndDate(date)
                    }
                )
            }
        }
    }
}

#Preview {
    AddFoodView(initialSelectedMeal: .breakfast)
        .environmentObject(TodayViewModel())
}
