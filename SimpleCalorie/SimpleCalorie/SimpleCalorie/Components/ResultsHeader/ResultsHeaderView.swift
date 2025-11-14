import SwiftUI

struct ResultsHeaderView: View {
    let count: Int

    var body: some View {
        HStack {
            Text("\(count) RESULTS")
                .font(AppFont.labelCapsSm(11))
                .foregroundStyle(AppColor.textMuted)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.sm)
    }
}

#Preview { ResultsHeaderView(count: 8) }

