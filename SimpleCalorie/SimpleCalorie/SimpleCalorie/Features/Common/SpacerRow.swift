import SwiftUI

struct SpacerRow: View {
    var height: CGFloat = 8
    var body: some View {
        Color.clear
            .frame(height: height)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

