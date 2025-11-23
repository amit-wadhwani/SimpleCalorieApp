import SwiftUI

enum TodaySheet: Identifiable, Equatable {
    case datePicker
    case addFood(initialMeal: MealType)

    var id: String {
        switch self {
        case .datePicker: return "datePicker"
        case .addFood(let m): return "addFood:\(m.rawValue)"
        }
    }
}

struct TodayScreen: View {
    @ObservedObject var viewModel: TodayViewModel
    @StateObject private var toastCenter = ToastCenter()
    @State private var activeSheet: TodaySheet?
    @State private var pendingScrollToMeal: MealType?

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                // Background
                AppColor.bgScreen
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1) Header: date row + kcal summary + macros (fixed)
                    VStack(spacing: AppSpace.s16) {
                        // Centered date row
                        TodayHeaderView(
                            selectedDate: $viewModel.selectedDate,
                            onDateTap: {
                                activeSheet = .datePicker
                            }
                        )
                        .environmentObject(viewModel)
                        .padding(.top, AppSpace.s12)
                        
                        // Single calorie summary card
                        CalorieSummaryCard(
                            consumed: viewModel.consumedCalories,
                            goal: viewModel.dailyGoalCalories
                        )
                        
                        // Single macros section
                        MacrosSectionView()
                            .environmentObject(viewModel)
                    }
                    .padding(.horizontal, AppSpace.s16)
                    .background(AppColor.bgScreen)
                    .overlay(
                        Rectangle()
                            .fill(AppColor.borderSubtle.opacity(0.6))
                            .frame(height: 0.5),
                        alignment: .bottom
                    )
                    
                    // 2) Scrollable zone: meals + ads + everything else
                    List {
                        // Motivation card
                        MotivationCardView()
                            .cardRowBackground(.single)
                        SpacerRow(height: 8)
                        
                        // Breakfast card
                        MealSectionList(
                            meal: .breakfast,
                            items: viewModel.meals.items(for: .breakfast),
                            onAddTap: { meal in
                                activeSheet = .addFood(initialMeal: meal)
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .breakfast // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO - delay to let swipe animation settle
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 120_000_000)
                                    toastCenter.show("Removed \(item.name) from \(meal.displayName).",
                                                     actionTitle: "Undo") {
                                        Haptics.light()
                                        viewModel.add(item, to: meal)
                                    }
                                }
                            },
                            viewModel: viewModel
                        )
                        .id(MealType.breakfast)
                        
                        if viewModel.showAds {
                            SpacerRow(height: TodayLayout.v1AdTopBottom)
                            AdCardView(model: AdCardView.sampleAds[0])
                                .cardRowBackground(.single)
                            SpacerRow(height: TodayLayout.v1AdTopBottom)
                        } else {
                            // No-ads path: insert decor spacer to preserve rhythm
                            DecorSpacerCard()
                        }
                        
                        // Lunch card
                        MealSectionList(
                            meal: .lunch,
                            items: viewModel.meals.items(for: .lunch),
                            onAddTap: { meal in
                                activeSheet = .addFood(initialMeal: meal)
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .lunch // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO - delay to let swipe animation settle
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 120_000_000)
                                    toastCenter.show("Removed \(item.name) from \(meal.displayName).",
                                                     actionTitle: "Undo") {
                                        Haptics.light()
                                        viewModel.add(item, to: meal)
                                    }
                                }
                            },
                            viewModel: viewModel
                        )
                        .id(MealType.lunch)
                        
                        if viewModel.showAds {
                            SpacerRow(height: TodayLayout.v1AdTopBottom)
                            AdCardView(model: AdCardView.sampleAds[1])
                                .cardRowBackground(.single)
                            SpacerRow(height: TodayLayout.v1AdTopBottom)
                        } else {
                            // No-ads path: insert decor spacer to preserve rhythm
                            DecorSpacerCard()
                        }
                        
                        // Dinner card
                        MealSectionList(
                            meal: .dinner,
                            items: viewModel.meals.items(for: .dinner),
                            onAddTap: { meal in
                                activeSheet = .addFood(initialMeal: meal)
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .dinner // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO - delay to let swipe animation settle
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 120_000_000)
                                    toastCenter.show("Removed \(item.name) from \(meal.displayName).",
                                                     actionTitle: "Undo") {
                                        Haptics.light()
                                        viewModel.add(item, to: meal)
                                    }
                                }
                            },
                            viewModel: viewModel
                        )
                        .id(MealType.dinner)
                        
                        if viewModel.showAds {
                            SpacerRow(height: TodayLayout.v1AdTopBottom)
                            AdCardView(model: AdCardView.sampleAds[2])
                                .cardRowBackground(.single)
                            SpacerRow(height: TodayLayout.v1AdTopBottom)
                        } else {
                            // No-ads path: insert decor spacer to preserve rhythm
                            DecorSpacerCard()
                        }
                        
                        // Snacks card
                        MealSectionList(
                            meal: .snacks,
                            items: viewModel.meals.items(for: .snacks),
                            onAddTap: { meal in
                                activeSheet = .addFood(initialMeal: meal)
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .snacks // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO - delay to let swipe animation settle
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 120_000_000)
                                    toastCenter.show("Removed \(item.name) from \(meal.displayName).",
                                                     actionTitle: "Undo") {
                                        Haptics.light()
                                        viewModel.add(item, to: meal)
                                    }
                                }
                            },
                            viewModel: viewModel
                        )
                        .id(MealType.snacks)
                        
                        // Final small spacer to keep symmetry
                        SpacerRow(height: TodayLayout.v1AdTopBottom)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .scrollContentBackground(.hidden)
                    .listRowSpacing(0) // kill all inter-row gaps; we'll add gaps explicitly
                    .environment(\.defaultMinListRowHeight, 0) // compact rows allowed
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        // transparent bumper that just creates scrollable space
                        Color.clear
                            .frame(height: 88) // ~56 (FAB) + 16–24 clearance; invisible space
                            .allowsHitTesting(false)
                    }
                    .onChange(of: pendingScrollToMeal) { oldValue, newValue in
                        guard let meal = newValue else { return }
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(meal, anchor: .center)
                        }
                        pendingScrollToMeal = nil
                    }
                }
            }
            .toast(center: toastCenter, avoidFAB: true)
            // Overlay FAB that always clears the home indicator / tab bar
            .overlay(alignment: .bottomTrailing) {
                FABSafeAreaHost(trailing: 16, clearance: 32) {
                    FloatingAddButton {
                        Haptics.light()
                        activeSheet = .addFood(initialMeal: AddFoodPreferences.lastSelected)
                    }
                    .accessibilityLabel("Add food")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .datePicker:
                DatePickerSheet(selectedDate: $viewModel.selectedDate) {
                    viewModel.setDate(viewModel.selectedDate)
                    activeSheet = nil
                }
            case .addFood(let initial):
                AddFoodView(initialSelectedMeal: initial) { item, meal in
                    withAnimation(.easeOut(duration: 0.22)) {
                        viewModel.add(item, to: meal)
                    }
                    AddFoodPreferences.set(meal)
                    pendingScrollToMeal = meal
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 160_000_000)
                        toastCenter.show("Added \(item.name) to \(meal.displayName).")
                    }
                    activeSheet = nil
                }
                .environmentObject(viewModel)
            }
        }
    }
    
    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: viewModel.selectedDate)
    }
}

#Preview {
    TodayScreen(viewModel: TodayViewModel())
}
