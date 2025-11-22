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

