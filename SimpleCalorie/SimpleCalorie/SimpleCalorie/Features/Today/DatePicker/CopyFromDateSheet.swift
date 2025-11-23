import SwiftUI

struct CopyFromDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TodayViewModel
    
    var body: some View {
        let mealTypeBinding = Binding<TodayViewModel.MealSuggestionTargetMealKind>(
            get: {
                let current = viewModel.copyFromDateTargetMealKind ?? .breakfast
                if viewModel.hasItems(on: viewModel.copyFromDateSelectedDate, mealKind: current) {
                    return current
                } else if let firstAvailable = TodayViewModel.MealSuggestionTargetMealKind.allCases.first(where: {
                    viewModel.hasItems(on: viewModel.copyFromDateSelectedDate, mealKind: $0)
                }) {
                    return firstAvailable
                } else {
                    return current
                }
            },
            set: { newValue in
                if viewModel.hasItems(on: viewModel.copyFromDateSelectedDate, mealKind: newValue) {
                    viewModel.copyFromDateTargetMealKind = newValue
                }
            }
        )

        return NavigationStack {
            VStack(spacing: 24) {
                // Date picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Date")
                        .font(.headline)
                        .foregroundStyle(AppColor.textTitle)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.copyFromDateSelectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(AppColor.brandPrimary)
                    .accessibilityIdentifier("copyFromDateDatePicker")
                }
                .padding(.horizontal)
                
                // Meal type picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Type")
                        .font(.headline)
                        .foregroundStyle(AppColor.textTitle)
                    
                    Picker("Meal Type", selection: mealTypeBinding) {
                        ForEach(TodayViewModel.MealSuggestionTargetMealKind.allCases, id: \.self) { kind in
                            let isAvailable = viewModel.hasItems(on: viewModel.copyFromDateSelectedDate, mealKind: kind)

                            HStack(spacing: 4) {
                                if isAvailable {
                                    Text(kind.displayName)
                                        .foregroundStyle(AppColor.textTitle)
                                } else {
                                    Image(systemName: "nosign")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(AppColor.textMuted)
                                }
                            }
                            .tag(kind)
                            .opacity(isAvailable ? 1.0 : 0.35)
                            .allowsHitTesting(isAvailable)
                            .disabled(!isAvailable)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("copyFromDateMealTypePicker")
                    .onChange(of: viewModel.copyFromDateSelectedDate) { _, newDate in
                        if let currentKind = viewModel.copyFromDateTargetMealKind,
                           !viewModel.hasItems(on: newDate, mealKind: currentKind) {
                            if let firstAvailable = viewModel.firstMealKindWithItems(on: newDate) {
                                viewModel.copyFromDateTargetMealKind = firstAvailable
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Preview section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)
                        .foregroundStyle(AppColor.textTitle)
                    
                    Text("Total: \(viewModel.previewTotalCaloriesForCopyFromDate) kcal • \(viewModel.previewItemsForCopyFromDate.count) items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColor.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("copyFromDatePreviewSummary")

                    if viewModel.previewItemsForCopyFromDate.isEmpty {
                        Text("No items for this date and meal.")
                            .font(.subheadline)
                            .foregroundStyle(AppColor.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .accessibilityIdentifier("copyFromDatePreviewEmpty")
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(viewModel.previewItemsForCopyFromDate) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.subheadline)
                                            .foregroundStyle(AppColor.textTitle)
                                        Spacer()
                                        Text("\(Int(item.calories)) kcal")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColor.textMuted)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .accessibilityIdentifier("copyFromDatePreviewList")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Copy from Date")
            .accessibilityIdentifier("copyFromDateSheetTitle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isCopyFromDateSheetPresented = false
                        dismiss()
                    }
                    .foregroundStyle(AppColor.brandPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Copy") {
                        Haptics.success()
                        viewModel.confirmCopyFromDate()
                        dismiss()
                    }
                    .foregroundStyle(viewModel.canConfirmCopyFromDate ? AppColor.brandPrimary : AppColor.textMuted)
                    .opacity(viewModel.canConfirmCopyFromDate ? 1.0 : 0.4)
                    .disabled(!viewModel.canConfirmCopyFromDate)
                    .accessibilityIdentifier("copyFromDateCopyButton")
                }
            }
        }
    }
}

#Preview {
    CopyFromDateSheet(viewModel: TodayViewModel())
}
