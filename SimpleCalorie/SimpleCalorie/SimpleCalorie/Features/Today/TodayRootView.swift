import SwiftUI

struct TodayRootView: View {
    @State private var selectedTab: MainTab = .today

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .today:
                    TodayScreen()
                case .weekly:
                    WeeklyPlaceholderView()
                case .profile:
                    ProfilePlaceholderView()
                }
            }

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

struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            Text("Profile coming soon")
                .navigationTitle("Profile")
        }
    }
}

#Preview {
    TodayRootView()
}

