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
        HStack(alignment: .center, spacing: AppSpace.s16) {
            // LEFT: name, serving, macros
            VStack(alignment: .leading, spacing: 4) {
                Text(props.name)
                    .font(AppFont.titleSm(15))
                    .foregroundStyle(AppColor.textTitle)

                Text(props.serving)
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted)

                HStack(spacing: AppSpace.s24) {
                    macroColumn(label: "PROTEIN", value: props.protein, color: AppColor.macroProtein)
                    macroColumn(label: "CARBS", value: props.carbs, color: AppColor.macroCarbs)
                    macroColumn(label: "FAT", value: props.fat, color: AppColor.macroFat)
                }
            }

            Spacer(minLength: AppSpace.s16)

            // RIGHT: kcal + plus
            VStack(alignment: .trailing, spacing: AppSpace.sm) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(props.kcal)
                        .font(AppFont.titleSm(15))
                        .foregroundStyle(AppColor.textTitle)

                    Text("kcal")
                        .font(AppFont.bodySm(11))
                        .foregroundStyle(AppColor.textMuted)
                }

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AppColor.textTitle)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Add \(props.name)"))
            }
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.vertical, AppSpace.s12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .shadow(color: AppColor.borderSubtle.opacity(0.4), radius: 6, x: 0, y: 2)
        )
    }

    @ViewBuilder
    private func macroColumn(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(AppFont.labelCapsSm(11))
                .foregroundStyle(AppColor.textMuted)
            Text(value)
                .font(AppFont.value(13))
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

