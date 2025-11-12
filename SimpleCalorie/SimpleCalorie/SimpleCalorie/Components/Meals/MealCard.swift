import SwiftUI

struct MealCard: View {
    let title: String
    let kcal: Int
    let items: [String]
    var onAddFood: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack {
                Text(title)
                    .font(AppFont.titleSm())
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                if kcal > 0 {
                    Text("\(kcal) kcal")
                        .font(AppFont.bodySmSmall())
                        .foregroundStyle(AppColor.textMuted)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColor.textMuted)
            }

            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(AppFont.bodySm())
                        .foregroundStyle(AppColor.textMuted)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColor.textMuted)
                }
            }

            Button(action: onAddFood) {
                HStack(spacing: AppSpace.xs) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Food")
                }
                .font(AppFont.bodySm())
                .foregroundStyle(AppColor.brandPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 1)
        )
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    VStack(spacing: AppSpace.s12) {
        MealCard(
            title: "Breakfast",
            kcal: 245,
            items: ["Oatmeal with berries", "Black coffee"],
            onAddFood: {}
        )
        MealCard(
            title: "Snacks",
            kcal: 0,
            items: ["No items yet"],
            onAddFood: {}
        )
    }
    .background(AppColor.bgScreen)
}
