import SwiftUI

private struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.18 : 0.22),
                    radius: configuration.isPressed ? 12 : 18,
                    x: 0, y: configuration.isPressed ? 6 : 8)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct FloatingAddButton: View {
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .padding(20)
                .background(
                    Circle()
                        .fill(AppColor.textTitle)
                )
        }
        .buttonStyle(FABButtonStyle())
        .accessibilityLabel("Add food")
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.2)
        FloatingAddButton {}
    }
}

