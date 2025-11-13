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
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColor.textTitle)
        }
        .padding(.horizontal, AppSpace.s12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.bgCard.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Search"))
    }
}

#Preview {
    StatefulPreviewWrapper("") { SearchBarView(placeholder: "Search database…", text: $0) }
}

