import SwiftUI

struct TodayTabBarView: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 40) {
            tabItem(.today)
            tabItem(.weekly)
            tabItem(.profile)
        }
        .padding(.horizontal, 32)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            AppColor.bgCard
                .ignoresSafeArea(edges: .bottom)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, y: -4)
    }

    private func tabItem(_ tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImageName)
                    .font(.system(size: 14, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? AppColor.brandPrimary : AppColor.textMuted)
        }
    }
}

#Preview {
    TodayTabBarView(selectedTab: .constant(.today))
        .background(AppColor.bgScreen)
}

