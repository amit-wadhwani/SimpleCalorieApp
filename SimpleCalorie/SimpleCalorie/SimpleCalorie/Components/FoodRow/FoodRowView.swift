import SwiftUI

struct FoodRowProps: Identifiable, Equatable {
    let id: UUID
    let name: String
    let serving: String   // "100g"
    let protein: String  // "31g"
    let carbs: String    // "0g"
    let fat: String      // "3.6g"
    let kcal: String     // "165"
}

struct FoodRowView: View {
    let props: FoodRowProps
    var onAdd: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(props.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text(props.kcal)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textTitle)

                    Text("kcal")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                }

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 44, height: 44) // ≥44pt tap
                        .background(
                            Circle().fill(AppColor.brandPrimary)
                        )
                        .foregroundStyle(.white)
                }
                .accessibilityLabel(Text("Add \(props.name)"))
            }

            Text(props.serving)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.textMuted)

            HStack(spacing: 24) {
                macroBlock(label: "PROTEIN", value: props.protein, color: AppColor.macroProtein)
                macroBlock(label: "CARBS",   value: props.carbs,   color: AppColor.macroCarbs)
                macroBlock(label: "FAT",     value: props.fat,     color: AppColor.macroFat)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, AppSpace.s12)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpace.s16)
    }

    @ViewBuilder
    private func macroBlock(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.textMuted)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    FoodRowView(props: .init(
        id: UUID(), name: "Chicken Breast", serving: "100g",
        protein: "31g", carbs: "0g", fat: "3.6g", kcal: "165"
    ))
}

