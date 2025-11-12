import SwiftUI

struct MacroRow: View {
    let label: String
    let value: Int
    let goal: Int
    let color: Color

    var progress: CGFloat {
        guard goal > 0 else { return 0 }
        return min(CGFloat(value) / CGFloat(goal), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            HStack {
                Text(label.uppercased())
                    .font(AppFont.labelCapsSm())
                    .foregroundStyle(AppColor.textMuted)

                Spacer()

                Text("\(value)g / \(goal)g")
                    .font(AppFont.bodySmSmall())
                    .foregroundStyle(AppColor.textMuted)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.borderSubtle)
                        .frame(height: 6)

                    Capsule()
                        .fill(color)
                        .frame(width: max(6, proxy.size.width * progress), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    VStack(spacing: AppSpace.md) {
        MacroRow(label: "Protein", value: 45, goal: 135, color: AppColor.macroProtein)
        MacroRow(label: "Carbs", value: 120, goal: 225, color: AppColor.macroCarbs)
        MacroRow(label: "Fat", value: 28, goal: 60, color: AppColor.macroFat)
    }
    .padding()
    .background(AppColor.bgScreen)
}

