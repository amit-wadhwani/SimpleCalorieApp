import SwiftUI

struct CardRowBackground: ViewModifier {
    enum Position { case single, top, middle, bottom }
    
    let position: Position
    let hInset: CGFloat = 16      // match other cards
    let corner: CGFloat = AppRadius.xl

    func shape() -> some Shape {
        switch position {
        case .single:
            return AnyShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        case .top:
            return AnyShape(UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: corner,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: corner
                )
            ))
        case .middle:
            return AnyShape(Rectangle())
        case .bottom:
            return AnyShape(UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: corner,
                    bottomTrailing: corner,
                    topTrailing: 0
                )
            ))
        }
    }

    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 0, leading: hInset, bottom: 0, trailing: hInset))
            .listRowBackground(Color.clear)
            .background(
                shape()
                    .fill(AppColor.bgCard)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
            .contentShape(Rectangle()) // full-width swipe target
            .mask(shape()) // hard-clip row content to card edge
            .compositingGroup() // ensure sublayers respect the mask
    }
}

extension View {
    func cardRowBackground(_ position: CardRowBackground.Position) -> some View {
        modifier(CardRowBackground(position: position))
    }
}

/// Tiny utility so we can return Shape from a function
private struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ s: S) { _path = { s.path(in: $0) } }
    func path(in rect: CGRect) -> Path { _path(rect) }
}

