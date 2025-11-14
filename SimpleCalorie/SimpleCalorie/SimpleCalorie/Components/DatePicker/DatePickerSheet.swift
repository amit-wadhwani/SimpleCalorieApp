import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(AppColor.brandPrimary)
                .padding()

                Spacer()
            }
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    selectedDate = Date()
                    dismiss()
                } label: {
                    Text("Today")
                        .font(AppFont.bodySm(14))
                        .foregroundStyle(AppColor.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpace.s12)
                        .background(AppColor.bgCard)
                        .cornerRadius(AppRadius.xl)
                }
                .padding(.horizontal, AppSpace.s16)
                .padding(.bottom, AppSpace.s16)
            }
        }
    }
}

#Preview {
    DatePickerSheet(selectedDate: .constant(Date()))
}

