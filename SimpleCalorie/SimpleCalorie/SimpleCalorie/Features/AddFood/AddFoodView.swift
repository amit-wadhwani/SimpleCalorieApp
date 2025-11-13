import SwiftUI

struct AddFoodView: View {
    @StateObject var viewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss
    let initialMeal: MealType
    @State private var selectedMeal: MealType

    init(viewModel: AddFoodViewModel, initialMeal: MealType = .breakfast) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.initialMeal = initialMeal
        self._selectedMeal = State(initialValue: initialMeal)
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBarView(title: "Add Food") {
                dismiss()
            }

            VStack(alignment: .leading, spacing: AppSpace.s16) {
                // Meal selector tabs
                MealSelectorTabs(selectedMeal: $selectedMeal)

                SearchBarView(placeholder: "Search database…", text: $viewModel.query)
                    .onChange(of: viewModel.query) { _, _ in
                        Task { await viewModel.refresh() }
                    }

                ResultsHeaderView(count: viewModel.rows.count)

                ScrollView {
                    VStack(spacing: AppSpace.s12) {
                        ForEach(viewModel.rows) { row in
                            FoodRowView(props: row) {
                                // TODO: selection action - add to selectedMeal
                            }
                        }
                    }
                    .padding(.top, AppSpace.s12)
                    .padding(.bottom, AppSpace.s24)
                }
                .scrollIndicators(.never)
            }
        }
        .background(AppColor.bgScreen.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    AddFoodView(viewModel: AddFoodViewModel(service: MockFoodSearchService()))
}

