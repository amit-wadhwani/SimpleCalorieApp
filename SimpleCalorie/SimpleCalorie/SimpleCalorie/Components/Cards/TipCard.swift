import SwiftUI

struct TipCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left blue crescent / pill
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColor.brandPrimary.opacity(0.1))
                .frame(width: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.brandPrimary)
                        .frame(width: 3),
                    alignment: .center
                )

            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.textTitle)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard)
                .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, AppSpace.s16)
    }
}

#Preview {
    TipCard(text: "If you ate like this every day... You'd lose 1.2 lbs/week")
        .background(AppColor.bgScreen)
}

