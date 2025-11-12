import SwiftUI

struct TodayHeaderView: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @Binding var selectedDate: Date
    var onDateTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row - placeholder for future brand icon
            HStack {
                // Placeholder for future brand icon
                Spacer().frame(width: 24, height: 24)

                Spacer()
            }

            // Date row - tappable (centered)
            HStack {
                Spacer()
                
                HStack(spacing: AppSpace.s16) {
                    Button {
                        viewModel.goToPreviousDay()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.textTitle)
                    }
                    
                    Button(action: onDateTap) {
                        Text(formattedDate())
                            .font(AppFont.titleSm(16))
                            .foregroundStyle(AppColor.textTitle)
                            .padding(.horizontal, AppSpace.s12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(AppColor.bgCard.opacity(0.8))
                            )
                    }
                    
                    Button {
                        viewModel.goToNextDay()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.textTitle)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
        }
    }
    
    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: selectedDate)
    }
}

#Preview {
    TodayHeaderView(
        selectedDate: .constant(Date()),
        onDateTap: {}
    )
    .environmentObject(TodayViewModel())
    .background(AppColor.bgScreen)
}

