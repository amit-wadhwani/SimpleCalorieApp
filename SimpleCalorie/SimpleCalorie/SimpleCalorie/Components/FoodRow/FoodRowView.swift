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
        HStack(alignment: .top, spacing: AppSpace.s16) {
            // Left column
            VStack(alignment: .leading, spacing: 4) {
                Text(props.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Text(props.serving)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(AppColor.textMuted)

                HStack(spacing: 16) {
                    macroBlock(label: "PROTEIN", value: props.protein, color: AppColor.macroProtein)
                    macroBlock(label: "CARBS",   value: props.carbs,   color: AppColor.macroCarbs)
                    macroBlock(label: "FAT",     value: props.fat,     color: AppColor.macroFat)
                }
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 12)

            // Right column
            VStack(alignment: .trailing, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(props.kcal)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.textTitle)
                    Text("kcal")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                }

                Spacer(minLength: 0)

                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppColor.brandPrimary)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .accessibilityLabel(Text("Add \(props.name)"))
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.vertical, AppSpace.s12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
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

