import SwiftUI

struct ResultsHeaderView: View {
    let count: Int

    var body: some View {
        Text("\(count) RESULTS")
            .font(AppFont.labelCapsSm())
            .foregroundStyle(AppColor.textMuted)
            .padding(.horizontal, AppSpace.s16)
            .padding(.top, AppSpace.s16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)
    }
}

#Preview { ResultsHeaderView(count: 8) }

