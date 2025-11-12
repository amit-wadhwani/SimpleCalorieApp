import SwiftUI

struct TodayTabBarView: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: AppSpace.s16) {
            tabItem(.today)
            tabItem(.weekly)
            tabItem(.settings)
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.sm)
        .padding(.bottom, max(AppSpace.sm, 8))
        .frame(maxWidth: .infinity)
        .background(AppColor.bgCard.ignoresSafeArea(edges: .bottom))
        .shadow(color: AppColor.borderSubtle.opacity(0.5), radius: 8, x: 0, y: -2)
    }

    private func tabItem(_ tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImageName)
                    .font(.system(size: 17, weight: .regular))
                Text(tab.title)
                    .font(AppFont.labelCapsSm(11))
            }
            .foregroundStyle(selectedTab == tab ? AppColor.brandPrimary : AppColor.textMuted)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TodayTabBarView(selectedTab: .constant(.today))
        .background(AppColor.bgScreen)
}

