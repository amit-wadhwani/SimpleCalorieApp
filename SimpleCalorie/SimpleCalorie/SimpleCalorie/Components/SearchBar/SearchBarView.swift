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
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppColor.textTitle)
        }
        .padding(.horizontal, AppSpace.s12)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColor.bgScreen)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColor.borderSubtle, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpace.s16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Search"))
    }
}

#Preview {
    StatefulPreviewWrapper("") { SearchBarView(placeholder: "Search database…", text: $0) }
}

