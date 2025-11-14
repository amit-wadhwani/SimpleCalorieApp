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
        NavigationStack {
            VStack(spacing: 0) {
                TopBarView(title: "Add Food") {
                    dismiss()
                }

                MealTabsView(selectedMeal: $activeMeal)

                SearchBarView(placeholder: "Search database...", text: $query)
                    .onChange(of: query) { _, newValue in
                        searchViewModel.query = newValue
                        Task { await searchViewModel.refresh() }
                    }

                ResultsHeaderView(count: searchViewModel.rows.count)

                ScrollView {
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
                                
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    todayViewModel.add(foodItem, to: activeMeal)
                                }
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                dismiss()
                            }
                        }
                        .padding(.horizontal, AppSpace.s16)

                        Spacer(minLength: AppSpace.s24)
                    }
                    .padding(.top, 8)
                }
                .scrollIndicators(.never)
            }
            .background(AppColor.bgScreen.ignoresSafeArea())
            .navigationBarHidden(true)
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
