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
    private var dismissWorkItems: [UUID: DispatchWorkItem] = [:]
    private var lastEnqueue: (text: String, time: CFAbsoluteTime)?

    @MainActor
    func show(_ text: String,
              actionTitle: String? = nil,
              action: (() -> Void)? = nil,
              duration: TimeInterval = 2.2) {
        let now = CFAbsoluteTimeGetCurrent()
        if let last = lastEnqueue, last.text == text, (now - last.time) < 0.2 {
            return // coalesce identical messages within 200ms
        }
        lastEnqueue = (text, now)
        let toast = Toast(text: text, actionTitle: actionTitle, action: action)
        queue.append(toast)
        process(duration: duration)
    }

    @MainActor
    func dismiss() {
        if let currentId = current?.id {
            dismissWorkItems[currentId]?.cancel()
            dismissWorkItems[currentId] = nil
        }
        current = nil
        if !queue.isEmpty { queue.removeFirst() }
        showing = false
        // allow exit animation to complete before showing next
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            Task { @MainActor in
                self?.process()
            }
        }
    }

    private func process(duration: TimeInterval = 2.2) {
        guard !showing, let next = queue.first else { return }
        showing = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            current = next
        }
        scheduleAutoDismiss(id: next.id, after: duration)
    }
    
    private func scheduleAutoDismiss(id: UUID, after seconds: TimeInterval) {
        dismissWorkItems[id]?.cancel()
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                guard let self = self, self.current?.id == id else { return }
                self.dismiss()
            }
        }
        dismissWorkItems[id] = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }
}

private struct ToastPresenter: ViewModifier {
    @ObservedObject var center: ToastCenter

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            // Full-screen pass-through base
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
            
            content
            
            // The actual toast view (tappable if it has a button)
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
            }
        }
    }
}

extension View {
    func toast(center: ToastCenter) -> some View {
        modifier(ToastPresenter(center: center))
    }
}

