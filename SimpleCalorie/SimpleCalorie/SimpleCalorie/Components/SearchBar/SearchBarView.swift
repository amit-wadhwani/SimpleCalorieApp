import SwiftUI

struct SearchBarView: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColor.textMuted)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(AppFont.bodySm(13))
                .foregroundStyle(AppColor.textTitle)
        }
        .padding(.horizontal, AppSpace.s12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
        )
        .padding(.top, AppSpace.s12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Search"))
    }
}

#Preview {
    StatefulPreviewWrapper("") { SearchBarView(placeholder: "Search database…", text: $0) }
}

