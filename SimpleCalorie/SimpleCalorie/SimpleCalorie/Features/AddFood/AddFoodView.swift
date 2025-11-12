import SwiftUI

struct AddFoodView: View {
    @StateObject var viewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TopBarView(title: "Add Food") {
                    dismiss()
                }

                SearchBarView(placeholder: "Search database…", text: $viewModel.query)
                    .onChange(of: viewModel.query) { _, _ in
                        Task { await viewModel.refresh() }
                    }

                ResultsHeaderView(count: viewModel.rows.count)

                VStack(spacing: AppSpace.s16) {
                    ForEach(viewModel.rows) { row in
                        FoodRowView(props: row) {
                            // TODO: selection action
                        }
                    }
                }
                .padding(.top, AppSpace.s16)
            }
            .padding(.bottom, AppSpace.s30)
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    AddFoodView(viewModel: AddFoodViewModel(service: MockFoodSearchService()))
}

