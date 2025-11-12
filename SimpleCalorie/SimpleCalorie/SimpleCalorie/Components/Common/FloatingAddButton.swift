import SwiftUI

struct FloatingAddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .padding(20)
                .background(
                    Circle()
                        .fill(AppColor.textTitle)
                        .shadow(
                            color: Color.black.opacity(0.18),
                            radius: 18,
                            x: 0,
                            y: 8
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.2)
        FloatingAddButton {}
    }
}

