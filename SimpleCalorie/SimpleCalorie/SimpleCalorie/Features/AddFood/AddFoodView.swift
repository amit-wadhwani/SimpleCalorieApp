import SwiftUI
import UIKit

struct AddFoodView: View {
    @EnvironmentObject var todayViewModel: TodayViewModel
    @StateObject private var searchViewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss
    let selectedMeal: MealType
    
    @State private var activeMeal: MealType
    @State private var query: String = ""

    init(selectedMeal: MealType) {
        self.selectedMeal = selectedMeal
        self._activeMeal = State(initialValue: selectedMeal)
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
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                // Dismiss sheet
                                dismiss()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.bottom, AppSpace.s16)
                }
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
