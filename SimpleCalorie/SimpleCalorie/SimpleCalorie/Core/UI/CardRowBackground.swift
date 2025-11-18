import SwiftUI

public enum CardRowPosition {
    case single, top, middle, bottom
}

private struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ shape: S) {
        _path = { rect in shape.path(in: rect) }
    }
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

private extension CardRowPosition {
    var shape: AnyShape {
        let r = TodayLayout.cardCorner
        
        switch self {
        case .single:
            return AnyShape(
                RoundedRectangle(
                    cornerRadius: r,
                    style: .continuous
                )
            )
        case .top:
            return AnyShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: r,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: r,
                    style: .continuous
                )
            )
        case .middle:
            return AnyShape(Rectangle())
        case .bottom:
            return AnyShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: r,
                    bottomTrailingRadius: r,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
        }
    }
}

private struct RowChrome: View {
    let shape: AnyShape
    
    var body: some View {
        shape
            .fill(AppColor.bgCard)
            // No outer stroke: avoids phantom divider lines at card joints
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 1)
            .allowsHitTesting(false)
    }
}

public struct CardRowBackground: ViewModifier {
    let position: CardRowPosition
    
    public func body(content: Content) -> some View {
        let s = position.shape
        
        return content
            // Draw the rounded card chrome directly behind the row content
            // so the card and its chrome move together during swipe.
            .background(
                RowChrome(shape: s)
            )
            // Clip content + chrome + swipe action sheet to the same card shape.
            .clipShape(s)
            // Now apply horizontal breathing room so the visible card is inset.
            .padding(.horizontal, TodayLayout.v1CardInsetH)
            // The List row itself remains edge-to-edge; card width is controlled by padding.
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

public extension View {
    func cardRowBackground(_ pos: CardRowPosition) -> some View {
        modifier(CardRowBackground(position: pos))
    }
}
