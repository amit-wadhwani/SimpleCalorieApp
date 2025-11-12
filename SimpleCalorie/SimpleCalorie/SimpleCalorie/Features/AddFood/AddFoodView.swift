import SwiftUI

struct AddFoodView: View {
    @StateObject var viewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            TopBarView(title: "Add Food") {
                dismiss()
            }

            SearchBarView(placeholder: "Search database…", text: $viewModel.query)
                .padding(.top, AppSpace.s16)
                .onChange(of: viewModel.query) { _, _ in
                    Task { await viewModel.refresh() }
                }

            ResultsHeaderView(count: viewModel.rows.count)

            ScrollView {
                VStack(spacing: AppSpace.s16) {
                    ForEach(viewModel.rows) { row in
                        FoodRowView(props: row) {
                            // TODO: selection action
                        }
                    }
                }
                .padding(.top, AppSpace.s12)
                .padding(.bottom, AppSpace.s24)
            }
            .scrollIndicators(.never)
        }
        .background(AppColor.bgScreen.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    AddFoodView(viewModel: AddFoodViewModel(service: MockFoodSearchService()))
}

