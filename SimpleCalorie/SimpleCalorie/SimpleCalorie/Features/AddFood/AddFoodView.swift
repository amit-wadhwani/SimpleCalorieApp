import SwiftUI
import UIKit

struct AddFoodView: View {
    @EnvironmentObject var todayViewModel: TodayViewModel
    @StateObject private var searchViewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss
    var onFoodAdded: ((FoodItem, MealType) -> Void)? = nil
    
    @State private var activeMeal: MealType
    @State private var query: String = ""

    init(initialSelectedMeal: MealType, onFoodAdded: ((FoodItem, MealType) -> Void)? = nil) {
        self.onFoodAdded = onFoodAdded
        self._activeMeal = State(initialValue: initialSelectedMeal) // source of truth on open
        self._searchViewModel = StateObject(wrappedValue: AddFoodViewModel(service: MockFoodSearchService()))
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
                        ForEach(searchViewModel.rows) { row in
                            FoodRowView(props: row) {
                                // Convert FoodRowProps to FoodItem with macros
                                let foodItem = FoodItem(
                                    name: row.name,
                                    calories: Int(row.kcal) ?? 0,
                                    description: row.serving,
                                    protein: parseMacro(row.protein),
                                    carbs: parseMacro(row.carbs),
                                    fat: parseMacro(row.fat)
                                )
                                
                                // Add food to the correct meal
                                add(foodItem)
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
    }
    
    private func parseMacro(_ str: String) -> Double {
        let cleaned = str.replacingOccurrences(of: "g", with: "").trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0
    }
    
    private func add(_ item: FoodItem) {
        // Fire callback to Today (which will update preferences)
        onFoodAdded?(item, activeMeal)
        Haptics.success()
        // Dismiss sheet
        dismiss()
    }
}

#Preview {
    AddFoodView(initialSelectedMeal: .breakfast)
        .environmentObject(TodayViewModel())
}
