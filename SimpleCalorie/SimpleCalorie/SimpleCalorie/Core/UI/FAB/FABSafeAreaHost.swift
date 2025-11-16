import SwiftUI

/// Positions its content above the bottom system areas (home indicator / tab bar),
/// with an extra clearance for visual breathing room.
struct FABSafeAreaHost<Content: View>: View {
    let trailing: CGFloat
    let clearance: CGFloat
    @ViewBuilder var content: () -> Content

    init(trailing: CGFloat = 16, clearance: CGFloat = 32, @ViewBuilder content: @escaping () -> Content) {
        self.trailing = trailing
        self.clearance = clearance
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            // The base layer spans the screen but does NOT intercept taps.
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .overlay(
                    content()
                        .padding(.trailing, trailing)
                        .padding(.bottom, max(16, geo.safeAreaInsets.bottom) + clearance)
                    , alignment: .bottomTrailing
                )
        }
        // Make sure this view sits above list rows but below toasts if any
        .zIndex(2)
    }
}

