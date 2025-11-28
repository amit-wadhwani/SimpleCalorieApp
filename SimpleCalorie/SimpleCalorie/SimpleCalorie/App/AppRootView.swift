import SwiftUI

struct AppRootView: View {
    var body: some View {
        VStack(spacing: 0) {
            #if DEBUG
            FDCKeyWarningBanner(apiKeyPresent: FDCClientConfig.shared.apiKey != nil)
            #endif
            
            TodayRootView()
        }
    }
}

#Preview {
    AppRootView()
}

