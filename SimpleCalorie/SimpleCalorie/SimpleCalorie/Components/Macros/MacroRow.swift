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
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                Text("\(value)g / \(goal)g")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppColor.textMuted)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.borderSubtle.opacity(0.3))
                        .frame(height: 8)

                    Capsule()
                        .fill(color)
                        .frame(width: max(8, proxy.size.width * progress), height: 8)
                }
            }
            .frame(height: 8)
            .animation(.easeInOut(duration: 0.35), value: value)
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

