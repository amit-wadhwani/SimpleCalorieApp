import SwiftUI

struct MacrosSectionView: View {
    @EnvironmentObject var viewModel: TodayViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MACROS")
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(AppColor.textMuted)
                .padding(.horizontal, AppSpace.s16)

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
        }
        .padding(.vertical, AppSpace.s16)
    }
}

#Preview {
    MacrosSectionView()
        .environmentObject(TodayViewModel())
        .background(AppColor.bgScreen)
}

