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
    @AppStorage(DetailSheetLayoutVariant.storageKey) private var layoutVariantRaw: String = DetailSheetLayoutVariant.controlsAbove.rawValue
    @AppStorage(HeartStyleVariant.storageKey) private var heartVariantRaw: String = HeartStyleVariant.flat.rawValue
    @AppStorage("nutrition.macroLabelsUppercase") var macroLabelsUppercase: Bool = true
    @AppStorage("nutrition.micronutrientIconMode") private var micronutrientIconModeRaw: String = "neutralDot"
    @AppStorage("nutrition.showInlineHints") private var showInlineHints: Bool = true
    
    private var layoutVariant: DetailSheetLayoutVariant {
        DetailSheetLayoutVariant(rawValue: layoutVariantRaw) ?? .controlsAbove
    }
    
    private var heartVariant: HeartStyleVariant {
        HeartStyleVariant(rawValue: heartVariantRaw) ?? .flat
    }

    var body: some View {
        NavigationStack {
            List {
                Section("APP") {
                    Toggle("Show Ads", isOn: $showAds)
                }
                
                Section("Detail Sheet Experiments") {
                    Picker("Layout", selection: $layoutVariantRaw) {
                        Text("Controls above").tag(DetailSheetLayoutVariant.controlsAbove.rawValue)
                        Text("Calories above").tag(DetailSheetLayoutVariant.caloriesAbove.rawValue)
                    }
                    
                    Picker("Heart Style", selection: $heartVariantRaw) {
                        Text("Flat").tag(HeartStyleVariant.flat.rawValue)
                        Text("Pill").tag(HeartStyleVariant.pill.rawValue)
                    }
                    
                    Toggle("Macro labels in ALL CAPS", isOn: $macroLabelsUppercase)
                    
                    Picker("Nutrient icons", selection: $micronutrientIconModeRaw) {
                        Text("Signal colors").tag("signal")
                        Text("Neutral dot").tag("neutralDot")
                        Text("No icon").tag("none")
                    }
                    
                    Toggle("Always show nutrient context", isOn: $showInlineHints)
                }

                Section("ACCOUNT") {
                    Text("Profile (coming soon)")
                }
                
                #if DEBUG
                Section("DEBUG") {
                    NavigationLink("Food Repo Mode") {
                        FoodRepositoryModeDebugView()
                    }
                    
                    NavigationLink("Food Repo Diagnostics") {
                        let repo = FoodRepositoryFactory.makeRepository(mode: FoodRepositoryModeSetting.current())
                        FoodRepositoryDiagnosticsView(repository: repo)
                    }
                    
                    NavigationLink("Run Provider Nutrient Sweep (FDC)") {
                        let repo = FoodRepositoryFactory.makeRepository(mode: FoodRepositoryModeSetting.current())
                        NutrientSweepDebugView(repository: repo)
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    TodayRootView()
}

