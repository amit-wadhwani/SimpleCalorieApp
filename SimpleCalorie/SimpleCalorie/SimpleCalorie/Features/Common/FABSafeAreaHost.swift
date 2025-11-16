import SwiftUI

/// Positions its content above the bottom system areas (home indicator / tab bar),
/// with an extra clearance for visual breathing room.
struct FABSafeAreaHost<Content: View>: View {
    private let clearance: CGFloat = 32 // extra gap above home indicator/tab bar
    private let trailing: CGFloat = 16   // matches card gutter
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            content
                .padding(.trailing, trailing)
                // Ensure the button always clears bottom UI:
                .padding(.bottom, max(16, geometry.safeAreaInsets.bottom) + clearance)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .zIndex(2) // sit above list rows
    }
}

