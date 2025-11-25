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
    
    @AppStorage(TodayQuickAddMode.storageKey)
    private var quickAddModeRaw: String = TodayQuickAddMode.suggestions.rawValue
    
    private var quickAddMode: TodayQuickAddMode {
        get { TodayQuickAddMode(rawValue: quickAddModeRaw) ?? .suggestions }
        set { quickAddModeRaw = newValue.rawValue }
    }
    
    @AppStorage(TodaySuggestionsLayoutMode.storageKey)
    private var suggestionsLayoutRaw: String = TodaySuggestionsLayoutMode.horizontal.rawValue
    
    private var suggestionsLayoutMode: TodaySuggestionsLayoutMode {
        get { TodaySuggestionsLayoutMode(rawValue: suggestionsLayoutRaw) ?? .horizontal }
        set { suggestionsLayoutRaw = newValue.rawValue }
    }
    
    @AppStorage(TodaySwipeEdgeMode.storageKey)
    private var swipeEdgeRaw: String = TodaySwipeEdgeMode.trailing.rawValue
    
    private var swipeEdgeMode: TodaySwipeEdgeMode {
        get { TodaySwipeEdgeMode(rawValue: swipeEdgeRaw) ?? .trailing }
        set { swipeEdgeRaw = newValue.rawValue }
    }
    
    @AppStorage(TodayCollapsedMacrosStyle.storageKey)
    private var collapsedMacrosRaw: String = TodayCollapsedMacrosStyle.capsule.rawValue
    
    private var collapsedMacrosStyle: TodayCollapsedMacrosStyle {
        get {
            if let style = TodayCollapsedMacrosStyle(rawValue: collapsedMacrosRaw) {
                return style
            } else if collapsedMacrosRaw == "minimalistLines" {
                return .verticalLines
            } else if collapsedMacrosRaw == "coloredBadgeRounded" {
                // Migrate Badge Rounded to Badge Fill
                return .badgeFill
            } else if collapsedMacrosRaw == "inline" || collapsedMacrosRaw == "coloredBadges" || collapsedMacrosRaw == "dotProgress" || collapsedMacrosRaw == "filledCapsules" || collapsedMacrosRaw == "coloredBadgeFill" {
                // Migrate old styles to capsule (simple)
                return .capsule
            } else {
                return .capsule
            }
        }
        set { collapsedMacrosRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("APP") {
                    Toggle("Show Ads", isOn: $showAds)
                }
                
                Section("QUICK ADD STYLE") {
                    Picker("Quick Add", selection: Binding(
                        get: { quickAddMode },
                        set: { quickAddModeRaw = $0.rawValue }
                    )) {
                        ForEach(TodayQuickAddMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("quickAddModePicker")
                }
                
                Section("SUGGESTION LAYOUT") {
                    Picker("Layout", selection: Binding(
                        get: { suggestionsLayoutMode },
                        set: { suggestionsLayoutRaw = $0.rawValue }
                    )) {
                        ForEach(TodaySuggestionsLayoutMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("SWIPE DIRECTION") {
                    Picker("Swipe Direction", selection: Binding(
                        get: { swipeEdgeMode },
                        set: { swipeEdgeRaw = $0.rawValue }
                    )) {
                        ForEach(TodaySwipeEdgeMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("COLLAPSED MACROS STYLE") {
                    Picker("Style", selection: Binding(
                        get: { collapsedMacrosStyle },
                        set: { collapsedMacrosRaw = $0.rawValue }
                    )) {
                        ForEach(TodayCollapsedMacrosStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
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

