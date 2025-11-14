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
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            // Top row: name, serving, calories, add button
            HStack(alignment: .top, spacing: AppSpace.s12) {
                // Left column: name and serving
                VStack(alignment: .leading, spacing: 4) {
                    Text(props.name)
                        .font(AppFont.value(15))
                        .foregroundStyle(AppColor.textTitle)

                    Text(props.serving)
                        .font(AppFont.bodySm(12))
                        .foregroundStyle(AppColor.textMuted)
                }

                Spacer()

                // Calories + add button
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(props.kcal) kcal")
                        .font(AppFont.value(14))
                        .foregroundStyle(AppColor.textMuted)

                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(AppColor.brandPrimary)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Add \(props.name)"))
                }
            }
            
            // Bottom row: macros in horizontal layout
            HStack(spacing: AppSpace.s24) {
                macroRow(label: "PROTEIN", value: props.protein, color: AppColor.macroProtein)
                macroRow(label: "CARBS", value: props.carbs, color: AppColor.macroCarbs)
                macroRow(label: "FAT", value: props.fat, color: AppColor.macroFat)
            }
            .padding(.top, AppSpace.sm)
        }
        .padding(AppSpace.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .shadow(color: AppColor.borderSubtle.opacity(0.4), radius: 6, x: 0, y: 2)
        )
    }

    @ViewBuilder
    private func macroRow(label: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(AppFont.section(11))
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

