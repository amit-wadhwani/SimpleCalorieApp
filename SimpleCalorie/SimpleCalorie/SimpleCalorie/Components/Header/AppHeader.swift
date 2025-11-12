import SwiftUI

struct AppHeader: View {
    @Binding var currentDate: Date
    @State private var isDatePickerPresented = false
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

            // Date navigation row - centered with closer chevrons
            HStack {
                Button {
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textMuted)
                }

                Spacer()

                Button(action: { isDatePickerPresented = true }) {
                    Text(formattedDate())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColor.textMuted)
                }

                Spacer()

                Button {
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .sheet(isPresented: $isDatePickerPresented) {
                NavigationStack {
                    VStack {
                        Text("Date picker coming soon")
                            .font(.headline)
                            .padding()
                        Spacer()
                    }
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                isDatePickerPresented = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
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

