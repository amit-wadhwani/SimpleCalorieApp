import SwiftUI

struct FloatingAddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AppColor.brandPrimary)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
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

