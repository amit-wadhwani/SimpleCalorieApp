import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType = .breakfast

    var body: some View {
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
                        onDelete: { item in
                            viewModel.remove(item, from: .breakfast)
                        }
                    )
                    
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
                        onDelete: { item in
                            viewModel.remove(item, from: .lunch)
                        }
                    )
                    
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
                        onDelete: { item in
                            viewModel.remove(item, from: .dinner)
                        }
                    )
                    
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
                        onDelete: { item in
                            viewModel.remove(item, from: .snacks)
                        }
                    )
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .scrollContentBackground(.hidden)
                .listRowSpacing(0) // kill all inter-row gaps; we'll add gaps explicitly
                .environment(\.defaultMinListRowHeight, 0) // compact rows allowed
                .safeAreaInset(edge: .bottom) {
                    Color.clear
                        .frame(height: 112) // 56(FAB) + 16(margin) + 24(home indicator) + a little cushion
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
        .sheet(isPresented: $viewModel.isDatePickerPresented) {
            DatePickerSheet(selectedDate: $viewModel.selectedDate)
        }
        .sheet(isPresented: $isShowingAddFood) {
            AddFoodView(selectedMeal: addFoodMeal)
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
