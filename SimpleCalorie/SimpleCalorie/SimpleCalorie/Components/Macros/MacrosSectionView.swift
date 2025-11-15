import SwiftUI

struct MacrosSectionView: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @State private var isCollapsed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MACROS")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(AppColor.textMuted)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        isCollapsed.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isCollapsed ? "Show" : "Hide")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColor.textMuted)

                        Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColor.textMuted)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 999)
                            .fill(AppColor.bgCard.opacity(0.9))
                    )
                }
            }
            .padding(.horizontal, AppSpace.s16)

            if !isCollapsed {
                VStack(alignment: .leading, spacing: 12) {
                    MacroRow(
                        label: "Protein",
                        value: Int(viewModel.protein),
                        goal: Int(viewModel.proteinGoal),
                        color: AppColor.macroProtein
                    )

                    MacroRow(
                        label: "Carbs",
                        value: Int(viewModel.carbs),
                        goal: Int(viewModel.carbsGoal),
                        color: AppColor.macroCarbs
                    )

                    MacroRow(
                        label: "Fat",
                        value: Int(viewModel.fat),
                        goal: Int(viewModel.fatGoal),
                        color: AppColor.macroFat
                    )
                }
                .padding(.top, AppSpace.sm)
            }
        }
        .padding(.vertical, AppSpace.s16)
    }
}

#Preview {
    MacrosSectionView()
        .environmentObject(TodayViewModel())
        .background(AppColor.bgScreen)
}

