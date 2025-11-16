import SwiftUI

final class ToastCenter: ObservableObject {
    struct Toast: Identifiable {
        let id = UUID()
        let text: String
        let actionTitle: String?
        let action: (() -> Void)?
    }

    @Published private(set) var queue: [Toast] = []

    func show(_ text: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        let t = Toast(text: text, actionTitle: actionTitle, action: action)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { queue.append(t) }
        Haptics.success()
        autoDismiss(t)
    }

    func remove(_ toast: Toast) {
        guard let i = queue.firstIndex(where: { $0.id == toast.id }) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { queue.remove(at: i) }
    }

    private func autoDismiss(_ toast: Toast) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.remove(toast)
        }
    }
}

private struct ToastPresenter: ViewModifier {
    @ObservedObject var center: ToastCenter

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            ForEach(center.queue) { toast in
                HStack(spacing: 12) {
                    Text(toast.text)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    if let title = toast.actionTitle {
                        Button(title) {
                            Haptics.light()
                            toast.action?()
                            center.remove(toast)
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.black.opacity(0.9))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 8)
                .padding(.bottom, 12 + 44) // above tab bar
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Notification")
            }
        }
    }
}

extension View {
    func toast(center: ToastCenter) -> some View {
        modifier(ToastPresenter(center: center))
    }
}

