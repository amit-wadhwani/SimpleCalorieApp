import SwiftUI

struct MacroBar: View {
    enum Kind { case protein, carbs, fat }

    let kind: Kind
    let current: Int
    let target: Int

    private var color: Color {
        switch kind {
        case .protein: return AppColor.macroProtein
        case .carbs:   return AppColor.macroCarbs
        case .fat:     return AppColor.macroFat
        }
    }

    private var title: String {
        switch kind {
        case .protein: return "Protein"
        case .carbs: return "Carbs"
        case .fat: return "Fat"
        }
    }

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(min(max(Double(current) / Double(target), 0), 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            HStack {
                Text(title)
                    .font(AppFont.bodySmSmall())
                    .foregroundStyle(AppColor.textMuted)
                Spacer()
                Text("\(current)g / \(target)g")
                    .font(AppFont.bodySmSmall())
                    .foregroundStyle(AppColor.textMuted)
            }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.black.opacity(0.06))
                    .frame(height: 6)

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    VStack(spacing: AppSpace.md) {
        MacroBar(kind: .protein, current: 45, target: 135)
        MacroBar(kind: .carbs, current: 120, target: 225)
        MacroBar(kind: .fat, current: 28, target: 60)
    }
    .padding()
}

