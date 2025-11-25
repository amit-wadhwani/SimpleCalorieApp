import SwiftUI

struct CopyFromDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TodayViewModel
    
    var body: some View {
        let mealTypeBinding = Binding<TodayViewModel.MealSuggestionTargetMealKind>(
            get: {
                let current = viewModel.copyFromDateSourceMealKind ?? .breakfast
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
                    viewModel.copyFromDateSourceMealKind = newValue
                }
            }
        )

        return NavigationStack {
            VStack(spacing: 16) {
                // Date picker with Today button
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Select Date")
                            .font(.headline)
                            .foregroundStyle(AppColor.textTitle)
                        
                        Spacer()
                        
                        Button("Today") {
                            viewModel.copyFromDateSelectedDate = Date()
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColor.brandPrimary)
                    }
                    
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
                        if let currentKind = viewModel.copyFromDateSourceMealKind,
                           !viewModel.hasItems(on: newDate, mealKind: currentKind) {
                            if let firstAvailable = viewModel.firstMealKindWithItems(on: newDate) {
                                viewModel.copyFromDateSourceMealKind = firstAvailable
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
                    
                    previewListScrollable
                }
                .padding(.horizontal)
                
                // Copy button (pinned at bottom)
                copyCTAButton
            }
            .padding(.bottom, 16)
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
    
    private var previewListScrollable: some View {
        Group {
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
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
                .frame(maxHeight: 220)
                .accessibilityIdentifier("copyFromDatePreviewList")
            }
        }
    }
    
    private var copyCTAButton: some View {
        Button(action: {
            if viewModel.canConfirmCopyFromDate {
                Haptics.success()
                viewModel.confirmCopyFromDate()
                dismiss()
            }
        }) {
            Text("Copy to \(destinationMealDisplayName())")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(viewModel.canConfirmCopyFromDate ? AppColor.brandPrimary : AppColor.borderSubtle)
                )
                .foregroundStyle(Color.white.opacity(viewModel.canConfirmCopyFromDate ? 1.0 : 0.6))
        }
        .disabled(!viewModel.canConfirmCopyFromDate)
        .padding(.horizontal)
    }
    
    private func destinationMealDisplayName() -> String {
        switch viewModel.copyFromDateDestinationMealKind {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        case .snacks:    return "Snacks"
        case nil:        return "Meal"
        }
    }
}

#Preview {
    CopyFromDateSheet(viewModel: TodayViewModel())
}
