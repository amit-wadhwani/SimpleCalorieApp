import SwiftUI

struct TodayRootView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var selectedTab: MainTab = .today

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .today:
                    TodayScreen()
                        .environmentObject(viewModel)
                case .weekly:
                    WeeklyPlaceholderView()
                case .settings:
                    SettingsView()
                }
            }
            
            // Bottom tab bar pinned to bottom
            TodayTabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// Simple placeholders for now
struct WeeklyPlaceholderView: View {
    var body: some View {
        NavigationStack {
            Text("Weekly view coming soon")
                .navigationTitle("Weekly")
        }
    }
}

struct SettingsView: View {
    @AppStorage("showAds") var showAds: Bool = true

    var body: some View {
        NavigationStack {
            List {
                Section("APP") {
                    Toggle("Show Ads", isOn: $showAds)
                }

                Section("ACCOUNT") {
                    Text("Profile (coming soon)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    TodayRootView()
}

