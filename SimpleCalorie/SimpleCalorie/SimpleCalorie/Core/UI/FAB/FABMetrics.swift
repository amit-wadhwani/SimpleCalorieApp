import SwiftUI

enum FABMetrics {
    /// Visual size of the floating button
    static let diameter: CGFloat = 56
    
    /// Outer spacing from edges to the FAB
    static let outerPadding: CGFloat = AppSpace.s16 // fallback 16 if needed
    
    /// How much trailing inset a bottom toast should reserve so its Undo button
    /// never sits under the FAB.
    static var trailingAvoidance: CGFloat { diameter + outerPadding }
}

