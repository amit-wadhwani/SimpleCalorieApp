import SwiftUI

struct ResultsHeaderView: View {
    let count: Int

    var body: some View {
        HStack {
            Text("\(count) RESULTS")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.textMuted)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, 8)
    }
}

#Preview { ResultsHeaderView(count: 8) }

