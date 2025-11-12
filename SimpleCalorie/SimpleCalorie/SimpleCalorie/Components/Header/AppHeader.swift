import SwiftUI

struct AppHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SimpleCalorie")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Text(formattedDate())
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppColor.textMuted)
            }

            Spacer()

            HStack(spacing: AppSpace.s12) {
                // Avatar placeholder
                Circle()
                    .fill(AppColor.brandPrimary.opacity(0.12))
                    .frame(width: 28, height: 28)
                    .overlay(Text("JD").font(.system(size: 11)).foregroundStyle(AppColor.brandPrimary))

                // Settings icon
                Button(action: { /* settings */ }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textMuted)
                }
            }
        }
        .padding(.horizontal, AppSpace.s16)
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

