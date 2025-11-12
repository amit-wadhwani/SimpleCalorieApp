import SwiftUI

struct AppHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack {
                Text("SimpleCalorie")
                    .font(AppFont.title(17))
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                HStack(spacing: AppSpace.s12) {
                    // Avatar placeholder
                    Circle()
                        .fill(AppColor.brandPrimary.opacity(0.12))
                        .frame(width: 28, height: 28)
                        .overlay(Text("JD").font(.system(size: 11)).foregroundStyle(AppColor.brandPrimary))

                    // Settings icon
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColor.textMuted)
                }
            }

            // Date line
            Text(formattedDate())
                .font(AppFont.bodySmSmall())
                .foregroundStyle(AppColor.textMuted)
        }
        .padding(.horizontal, AppSpace.s16)
        .padding(.top, AppSpace.s12)
    }
    
    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: .now)
    }
}

#Preview {
    AppHeader()
        .background(AppColor.bgScreen)
}

