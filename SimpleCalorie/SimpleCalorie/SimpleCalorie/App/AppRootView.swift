import SwiftUI

struct AppRootView: View {
    var body: some View {
        AddFoodView(viewModel: AddFoodViewModel(service: MockFoodSearchService()))
            .background(Color("pageBg")) // TODO(token: global/bg/page)
    }
}

#Preview {
    AppRootView()
}

