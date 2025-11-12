import SwiftUI

struct SearchBarView: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: AppSpace.s12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textMuted)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(AppFont.bodySm())
                .foregroundStyle(AppColor.textTitle)
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.vertical, AppSpace.s12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.full)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.full)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.s24) // 24–30 from top bar
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Search"))
    }
}

#Preview {
    StatefulPreviewWrapper("") { SearchBarView(placeholder: "Search database…", text: $0) }
}

