import SwiftUI

struct TodayTabBarView: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 40) {
            tabItem(.today)
            tabItem(.weekly)
            tabItem(.settings)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(AppColor.bgCard.ignoresSafeArea(edges: .bottom))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -2)
    }

    private func tabItem(_ tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImageName)
                    .font(.system(size: 22, weight: .regular))
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

