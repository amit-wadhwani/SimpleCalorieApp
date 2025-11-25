import SwiftUI

struct TodayRootView: View {
    @StateObject private var viewModel: TodayViewModel
    @State private var selectedTab: MainTab = .today

    init() {
        let args = ProcessInfo.processInfo.arguments
        let seedDemoData = !args.contains("UITEST_DISABLE_SEED_DATA")

        let viewModel: TodayViewModel
        
        if args.contains("UITEST_SEED_YESTERDAY_BREAKFAST") {
            let repo = InMemoryFoodRepository()
            if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
                _ = repo.add(
                    FoodItem(name: "UITest Oats", calories: 180, description: "1 bowl", protein: 6, carbs: 32, fat: 4),
                    to: .breakfast,
                    on: yesterday
                )
                _ = repo.add(
                    FoodItem(name: "UITest Coffee", calories: 5, description: "1 cup", protein: 0, carbs: 0, fat: 0),
                    to: .breakfast,
                    on: yesterday
                )
                
                viewModel = TodayViewModel(repo: repo, seedDemoData: seedDemoData)
            } else {
                viewModel = TodayViewModel(repo: repo, seedDemoData: seedDemoData)
            }
        } else {
            viewModel = TodayViewModel(seedDemoData: seedDemoData)
        }

        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .today:
                    TodayScreen(viewModel: viewModel)
                        .sheet(isPresented: $viewModel.isCopyFromDateSheetPresented) {
                            CopyFromDateSheet(viewModel: viewModel)
                        }
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

