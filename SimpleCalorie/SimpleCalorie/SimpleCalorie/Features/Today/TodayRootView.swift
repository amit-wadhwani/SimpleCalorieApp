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
                
                SettingsLayoutSection()
                
                Section("ACCOUNT") {
                    Text("Profile (coming soon)")
                }
            }
            .navigationTitle("Settings")
        }
    }
}


/// Controls the spacer style and height used when ads are disabled on Today.
struct SettingsLayoutSection: View {
    @AppStorage(TodayLayout.decorStyleKey) private var styleRaw: String = TodayLayout.DecorSpacerStyle.plain.rawValue
    @AppStorage(TodayLayout.decorVariantKey) private var variantRaw: String = TodayLayout.DecorSpacerVariant.oneLine.rawValue
    @AppStorage(TodayLayout.decorAlignKey) private var alignRaw: String = TodayLayout.DecorSpacerAlign.leading.rawValue
    
    private var styleBinding: Binding<Int> {
        Binding(
            get: {
                // Migrate old "decor" value to "capsule" automatically (one-time migration)
                let currentStyle = TodayLayout.DecorSpacerStyle(rawValue: styleRaw) ?? .plain
                if styleRaw == "decor" {
                    DispatchQueue.main.async {
                        styleRaw = TodayLayout.DecorSpacerStyle.capsule.rawValue
                    }
                }
                switch currentStyle {
                case .plain: return 0
                case .divider: return 1
                case .capsule: return 2
                case .capsuleNewTuned: return 3
                }
            },
            set: { newValue in
                let new: TodayLayout.DecorSpacerStyle
                switch newValue {
                case 0: new = .plain
                case 1: new = .divider
                case 2: new = .capsule
                case 3: new = .capsuleNewTuned
                default: new = .capsule
                }
                styleRaw = new.rawValue
            }
        )
    }
    
    private var variantBinding: Binding<Int> {
        Binding(
            get: {
                (TodayLayout.DecorSpacerVariant(rawValue: variantRaw) ?? .oneLine) == .twoLine ? 1 : 0
            },
            set: {
                variantRaw = ($0 == 1 ? TodayLayout.DecorSpacerVariant.twoLine : TodayLayout.DecorSpacerVariant.oneLine).rawValue
            }
        )
    }
    
    private var alignBinding: Binding<Int> {
        Binding(
            get: {
                (TodayLayout.DecorSpacerAlign(rawValue: alignRaw) ?? .leading) == .center ? 1 : 0
            },
            set: { newValue in
                alignRaw = (newValue == 1 ? TodayLayout.DecorSpacerAlign.center : .leading).rawValue
            }
        )
    }

    var body: some View {
        Section("Today Screen — No-Ads Separator") {
            Picker("Style", selection: styleBinding) {
                Text("Invisible").tag(0)
                Text("Divider").tag(1)
                Text("Old Capsule (centered)").tag(2)
                Text("New Capsule (tuned)").tag(3)
            }
            .pickerStyle(.segmented)
            
            if styleBinding.wrappedValue == 2 { // Old Capsule only
                Picker("Height", selection: variantBinding) {
                    Text("1-line").tag(0)
                    Text("2-line").tag(1)
                }
                .pickerStyle(.segmented)
                
                Picker("Alignment", selection: alignBinding) {
                    Text("Left").tag(0)
                    Text("Centered").tag(1)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    TodayRootView()
}

