import SwiftUI

struct FloatingAddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AppColor.brandPrimary)
                        .shadow(color: AppColor.brandPrimary.opacity(0.25), radius: 10, x: 0, y: 4)
                )
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.2)
        FloatingAddButton {}
    }
}

