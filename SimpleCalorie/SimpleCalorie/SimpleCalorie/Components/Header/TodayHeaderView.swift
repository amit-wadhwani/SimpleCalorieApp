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

            // Date row - tappable
            HStack(spacing: AppSpace.s12) {
                Button {
                    viewModel.goToPreviousDay()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.brandPrimary)
                }
                
                Button(action: onDateTap) {
                    Text(formattedDate())
                        .font(AppFont.titleSm(16))
                        .foregroundStyle(AppColor.textTitle)
                }
                
                Button {
                    viewModel.goToNextDay()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.brandPrimary)
                }
                
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

