import SwiftUI

struct FloatingAddButton: View {
    var action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(AppColor.brandPrimary)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            }
            .padding(.trailing, AppSpace.s16)
        }
        .padding(.bottom, AppSpace.s16)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.2)
        FloatingAddButton {}
    }
}

