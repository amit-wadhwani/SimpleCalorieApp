import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @StateObject private var toastCenter = ToastCenter()
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType? = nil
    @State private var pendingScrollToMeal: MealType?
    @AppStorage("addFood.lastSelectedMeal") private var lastSelectedMealRaw: String = MealType.breakfast.rawValue
    
    private var lastSelectedMeal: MealType {
        MealType(rawValue: lastSelectedMealRaw) ?? .breakfast
    }

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
                                viewModel.isDatePickerPresented = true
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
                        SpacerRow(height: 8)
                        
                        // Breakfast card
                        MealSectionList(
                            meal: .breakfast,
                            items: viewModel.meals[.breakfast] ?? [],
                            onAddTap: { meal in
                                addFoodMeal = meal
                                isShowingAddFood = true
                            },
                            onAddFood: { item, meal in
                                Haptics.light()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.add(item, to: meal)
                                }
                                pendingScrollToMeal = meal
                                // ADD: toast, NO UNDO
                                toastCenter.show("Added \(item.name) to \(meal.displayName)")
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .breakfast // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO
                                toastCenter.show("Removed \(item.name) from \(meal.displayName).", actionTitle: "Undo") {
                                    Haptics.light()
                                    viewModel.add(item, to: meal)
                                }
                            }
                        )
                        .id(MealType.breakfast)
                        
                        if viewModel.showAds {
                            SpacerRow(height: 8)
                            AdCardView(model: AdCardView.sampleAds[0])
                            SpacerRow(height: 8)
                        }
                        
                        // Lunch card
                        MealSectionList(
                            meal: .lunch,
                            items: viewModel.meals[.lunch] ?? [],
                            onAddTap: { meal in
                                addFoodMeal = meal
                                isShowingAddFood = true
                            },
                            onAddFood: { item, meal in
                                Haptics.light()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.add(item, to: meal)
                                }
                                pendingScrollToMeal = meal
                                // ADD: toast, NO UNDO
                                toastCenter.show("Added \(item.name) to \(meal.displayName)")
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .lunch // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO
                                toastCenter.show("Removed \(item.name) from \(meal.displayName).", actionTitle: "Undo") {
                                    Haptics.light()
                                    viewModel.add(item, to: meal)
                                }
                            }
                        )
                        .id(MealType.lunch)
                        
                        if viewModel.showAds {
                            SpacerRow(height: 8)
                            AdCardView(model: AdCardView.sampleAds[1])
                            SpacerRow(height: 8)
                        }
                        
                        // Dinner card
                        MealSectionList(
                            meal: .dinner,
                            items: viewModel.meals[.dinner] ?? [],
                            onAddTap: { meal in
                                addFoodMeal = meal
                                isShowingAddFood = true
                            },
                            onAddFood: { item, meal in
                                Haptics.light()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.add(item, to: meal)
                                }
                                pendingScrollToMeal = meal
                                // ADD: toast, NO UNDO
                                toastCenter.show("Added \(item.name) to \(meal.displayName)")
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .dinner // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO
                                toastCenter.show("Removed \(item.name) from \(meal.displayName).", actionTitle: "Undo") {
                                    Haptics.light()
                                    viewModel.add(item, to: meal)
                                }
                            }
                        )
                        .id(MealType.dinner)
                        
                        if viewModel.showAds {
                            SpacerRow(height: 8)
                            AdCardView(model: AdCardView.sampleAds[2])
                            SpacerRow(height: 8)
                        }
                        
                        // Snacks card
                        MealSectionList(
                            meal: .snacks,
                            items: viewModel.meals[.snacks] ?? [],
                            onAddTap: { meal in
                                addFoodMeal = meal
                                isShowingAddFood = true
                            },
                            onAddFood: { item, meal in
                                Haptics.light()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.add(item, to: meal)
                                }
                                pendingScrollToMeal = meal
                                // ADD: toast, NO UNDO
                                toastCenter.show("Added \(item.name) to \(meal.displayName)")
                            },
                            onDelete: { item in
                                Haptics.rigid()
                                let meal: MealType = .snacks // this section's meal
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.remove(item, from: meal)
                                }
                                pendingScrollToMeal = meal
                                // DELETE: toast WITH UNDO
                                toastCenter.show("Removed \(item.name) from \(meal.displayName).", actionTitle: "Undo") {
                                    Haptics.light()
                                    viewModel.add(item, to: meal)
                                }
                            }
                        )
                        .id(MealType.snacks)
                        
                        // Final small spacer to keep symmetry
                        SpacerRow(height: 24)
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
                // Overlay FAB that always clears the home indicator / tab bar
                .overlay(alignment: .bottomTrailing) {
                    FABSafeAreaHost {
                        FloatingAddButton {
                            // keep existing action (set addFoodMeal = lastSelectedMeal, show sheet, etc.)
                            addFoodMeal = lastSelectedMeal
                            isShowingAddFood = true
                        }
                        .accessibilityLabel("Add food")
                    }
                }
            }
            .toast(center: toastCenter)
        }
        .sheet(isPresented: $viewModel.isDatePickerPresented) {
            DatePickerSheet(selectedDate: $viewModel.selectedDate)
        }
        .sheet(isPresented: $isShowingAddFood) {
            AddFoodView(initialSelectedMeal: addFoodMeal ?? .breakfast) { item, meal in
                viewModel.add(item, to: meal)                   // route to the meal passed back
                toastCenter.show("Added to \(meal.displayName)") // info toast, no Undo for add
                pendingScrollToMeal = meal                      // autoscroll target
            }
            .environmentObject(viewModel)
        }
    }
    
    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: viewModel.selectedDate)
    }
}

#Preview {
    TodayScreen()
        .environmentObject(TodayViewModel())
}
