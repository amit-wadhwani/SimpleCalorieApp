import SwiftUI

@MainActor
final class ToastCenter: ObservableObject {
    struct Toast: Identifiable {
        let id = UUID()
        let text: String
        let actionTitle: String?
        let action: (() -> Void)?
    }

    @Published private(set) var current: Toast?
    private var queue: [Toast] = []
    private var showing = false
    private var dismissTask: Task<Void, Never>?

    func show(_ text: String,
              actionTitle: String? = nil,
              action: (() -> Void)? = nil,
              duration: TimeInterval = 2.2) {
        let toast = Toast(text: text, actionTitle: actionTitle, action: action)
        queue.append(toast)
        process(duration: duration)
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        current = nil
        if !queue.isEmpty { queue.removeFirst() }
        showing = false
        // allow exit animation to complete before showing next
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 80_000_000)
            process()
        }
    }

    private func process(duration: TimeInterval = 2.2) {
        guard !showing, let next = queue.first else { return }
        showing = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            current = next
        }
        dismissTask?.cancel()
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            dismiss()
        }
    }
}

private struct ToastPresenter: ViewModifier {
    @ObservedObject var center: ToastCenter

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let toast = center.current {
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
                            center.dismiss()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                        .allowsHitTesting(true) // button is tappable
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
                .zIndex(999)
                .allowsHitTesting(toast.actionTitle != nil) // banner doesn't block scrolling unless it has a button
            }
        }
    }
}

extension View {
    func toast(center: ToastCenter) -> some View {
        modifier(ToastPresenter(center: center))
    }
}

