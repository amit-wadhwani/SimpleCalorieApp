import SwiftUI

struct TodayRootView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var selectedTab: MainTab = .today

    var body: some View {
        Group {
            switch selectedTab {
            case .today:
                TodayScreen()
                    .environmentObject(viewModel)
                    .safeAreaInset(edge: .bottom) {
                        TodayTabBarView(selectedTab: $selectedTab)
                    }
            case .weekly:
                WeeklyPlaceholderView()
                    .safeAreaInset(edge: .bottom) {
                        TodayTabBarView(selectedTab: $selectedTab)
                    }
            case .settings:
                SettingsView()
                    .safeAreaInset(edge: .bottom) {
                        TodayTabBarView(selectedTab: $selectedTab)
                    }
            }
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
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Text("Profile (coming soon)")
                }

                Section("App") {
                    Text("Preferences (coming soon)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    TodayRootView()
}

