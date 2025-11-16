import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @StateObject private var toastCenter = ToastCenter()
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType = .breakfast
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
                            onAddTap: {
                                addFoodMeal = .breakfast
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
                                toastCenter.show("Removed \(item.name) from \(meal.displayName)", actionTitle: "Undo") {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        viewModel.add(item, to: meal)
                                    }
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
                            onAddTap: {
                                addFoodMeal = .lunch
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
                                toastCenter.show("Removed \(item.name) from \(meal.displayName)", actionTitle: "Undo") {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        viewModel.add(item, to: meal)
                                    }
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
                            onAddTap: {
                                addFoodMeal = .dinner
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
                                toastCenter.show("Removed \(item.name) from \(meal.displayName)", actionTitle: "Undo") {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        viewModel.add(item, to: meal)
                                    }
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
                            onAddTap: {
                                addFoodMeal = .snacks
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
                                toastCenter.show("Removed \(item.name) from \(meal.displayName)", actionTitle: "Undo") {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                        viewModel.add(item, to: meal)
                                    }
                                }
                            }
                        )
                        .id(MealType.snacks)
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .scrollContentBackground(.hidden)
                    .listRowSpacing(0) // kill all inter-row gaps; we'll add gaps explicitly
                    .environment(\.defaultMinListRowHeight, 0) // compact rows allowed
                    .safeAreaInset(edge: .bottom) {
                        Color.clear
                            .frame(height: 120) // 56 FAB + ~16 margin + ~24 home indicator + cushion
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
                
                // FAB positioned above tab bar
                HStack {
                    Spacer()
                    FloatingAddButton {
                        addFoodMeal = .breakfast
                        isShowingAddFood = true
                    }
                    .padding(.trailing, AppSpace.s16)
                    .padding(.bottom, 72) // sits above tab bar
                }
            }
            .toast(center: toastCenter)
        }
        .sheet(isPresented: $viewModel.isDatePickerPresented) {
            DatePickerSheet(selectedDate: $viewModel.selectedDate)
        }
        .sheet(isPresented: $isShowingAddFood) {
            AddFoodView(selectedMeal: addFoodMeal) { item, meal in
                // This closure is called when food is added from AddFoodView
                // AddFoodView already calls viewModel.add(), so we just handle toast/scroll here
                // Use the meal from the callback (activeMeal from AddFoodView), not addFoodMeal
                pendingScrollToMeal = meal
                // ADD: toast, NO UNDO
                toastCenter.show("Added \(item.name) to \(meal.displayName)")
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
