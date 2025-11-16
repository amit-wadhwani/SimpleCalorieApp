import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    var onDone: (() -> Void)?

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
                // Top-left: Today
                ToolbarItem(placement: .cancellationAction) {
                    Button("Today") {
                        selectedDate = Date()
                    }
                    .foregroundStyle(AppColor.brandPrimary)
                }

                // Top-right: Done
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Haptics.success()
                        onDone?()
                        dismiss()
                    }
                    .foregroundStyle(AppColor.brandPrimary)
                }
            }
        }
    }
}

#Preview {
    DatePickerSheet(selectedDate: .constant(Date()))
}

