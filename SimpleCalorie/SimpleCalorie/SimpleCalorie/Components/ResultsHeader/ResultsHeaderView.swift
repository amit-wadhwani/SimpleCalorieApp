import SwiftUI

struct ResultsHeaderView: View {
    let count: Int

    var body: some View {
        Text("\(count) RESULTS")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(AppColor.textMuted)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.horizontal, AppSpace.s16)
            .padding(.top, AppSpace.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)
    }
}

#Preview { ResultsHeaderView(count: 8) }

