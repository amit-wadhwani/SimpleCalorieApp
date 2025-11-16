import SwiftUI
import UIKit

struct AddFoodView: View {
    @EnvironmentObject var todayViewModel: TodayViewModel
    @StateObject private var searchViewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss
    let selectedMeal: MealType
    var onFoodAdded: ((FoodItem) -> Void)? = nil
    
    @AppStorage("addFood.lastTab") private var lastTabRaw: String = MealType.breakfast.rawValue
    @State private var activeMeal: MealType
    @State private var query: String = ""

    init(selectedMeal: MealType, onFoodAdded: ((FoodItem) -> Void)? = nil) {
        self.selectedMeal = selectedMeal
        self.onFoodAdded = onFoodAdded
        let savedMeal = MealType(rawValue: UserDefaults.standard.string(forKey: "addFood.lastTab") ?? MealType.breakfast.rawValue) ?? selectedMeal
        self._activeMeal = State(initialValue: savedMeal)
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
                    .onChange(of: activeMeal) { oldValue, newValue in
                        lastTabRaw = newValue.rawValue
                    }
                
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
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    todayViewModel.add(foodItem, to: activeMeal)
                                }
                                
                                // Call the onFoodAdded callback if provided
                                onFoodAdded?(foodItem)
                                
                                // Dismiss sheet
                                dismiss()
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
}

#Preview {
    AddFoodView(selectedMeal: .breakfast)
        .environmentObject(TodayViewModel())
}
