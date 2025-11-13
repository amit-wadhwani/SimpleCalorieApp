import SwiftUI

struct MacrosSectionView: View {
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
                    value: 45,
                    goal: 135,
                    color: AppColor.macroProtein
                )

                MacroRow(
                    label: "Carbs",
                    value: 120,
                    goal: 225,
                    color: AppColor.macroCarbs
                )

                MacroRow(
                    label: "Fat",
                    value: 28,
                    goal: 60,
                    color: AppColor.macroFat
                )
            }
        }
        .padding(.vertical, AppSpace.s16)
    }
}

#Preview {
    MacrosSectionView()
        .background(AppColor.bgScreen)
}

