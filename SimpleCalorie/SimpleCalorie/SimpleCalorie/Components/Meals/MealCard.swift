import SwiftUI

struct MealCard: View {
    let title: String
    let kcal: Int
    let items: [String]
    var onAddFood: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                if kcal > 0 {
                    Text("\(kcal) kcal")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                }
            }

            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppColor.textMuted)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColor.textMuted)
                }
            }

            Button(action: onAddFood) {
                HStack {
                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColor.brandPrimary)

                        Text("Add Food")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColor.brandPrimary)
                    }

                    Spacer()
                }
                .padding(.top, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AppSpace.s16)
        .padding(.horizontal, AppSpace.s16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
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
