import SwiftUI

struct TopBarView: View {
    let title: String
    var onBack: () -> Void = {}

    var body: some View {
        HStack(spacing: AppSpace.s12) {
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44) // ≥44pt tap
            }
            .accessibilityLabel(Text("Back"))

            Text(title)
                .font(AppFont.title())
                .foregroundStyle(AppColor.textTitle)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.s16)
        .padding(.bottom, 0)
    }
}

#Preview {
    TopBarView(title: "Add Food")
}

