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
            // Left column
            VStack(alignment: .leading, spacing: AppSpace.s12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(props.name)
                        .font(AppFont.titleSm())
                        .foregroundStyle(AppColor.textTitle)
                    Text(props.serving)
                        .font(AppFont.bodySm())
                        .foregroundStyle(AppColor.textMuted)
                }

                HStack(spacing: AppSpace.s24) {
                    macroBlock(label: "PROTEIN", value: props.protein, color: AppColor.macroProtein)
                    macroBlock(label: "CARBS",   value: props.carbs,   color: AppColor.macroCarbs)
                    macroBlock(label: "FAT",     value: props.fat,     color: AppColor.macroFat)
                }
            }
            Spacer(minLength: 0)

            // Right column
            VStack(alignment: .trailing, spacing: AppSpace.s12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(props.kcal)
                        .font(AppFont.titleSm(18)) // token: global/component/FoodRow/kcal/value/typography
                        .foregroundStyle(AppColor.textTitle)
                    Text("kcal")
                        .font(AppFont.captionXs())
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
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.vertical, AppSpace.s12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
                .shadow(radius: 0) // TODO(token: global/elevation/card) if we add
        )
        .padding(.horizontal, AppSpace.s16)
    }

    @ViewBuilder
    private func macroBlock(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(AppFont.bodySm())
                .foregroundStyle(AppColor.textMuted)
            Text(value)
                .font(AppFont.bodySm()) // token: global/component/FoodRow/macro/value/typography
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

