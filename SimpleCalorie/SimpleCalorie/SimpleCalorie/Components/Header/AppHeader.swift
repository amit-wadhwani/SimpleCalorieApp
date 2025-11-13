import SwiftUI

struct AppHeader: View {
    @Binding var currentDate: Date
    var onSettingsTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("SimpleCalorie")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColor.textTitle)

                Spacer()

                HStack(spacing: AppSpace.s12) {
                    // Avatar placeholder
                    Circle()
                        .fill(AppColor.brandPrimary.opacity(0.12))
                        .frame(width: 28, height: 28)
                        .overlay(Text("JD").font(.system(size: 11)).foregroundStyle(AppColor.brandPrimary))

                    // Settings icon
                    Button(action: { onSettingsTap?() }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.textMuted)
                    }
                }
            }

            // Date navigation row
            HStack {
                Button {
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.textMuted)
                }

                Spacer()

                Text(formattedDate())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColor.textMuted)

                Spacer()

                Button {
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.textMuted)
                }
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, AppSpace.s16)
    }
    
    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: currentDate)
    }
}

#Preview {
    AppHeader(currentDate: .constant(Date()))
        .background(AppColor.bgScreen)
}

