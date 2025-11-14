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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpace.s16) {
                    // Date row
                    TodayHeaderView(
                        selectedDate: $viewModel.selectedDate,
                        onDateTap: {
                            viewModel.isDatePickerPresented = true
                        }
                    )
                    .environmentObject(viewModel)
                    .padding(.top, AppSpace.s16)
                    
                    // Single calorie summary card
                    CalorieSummaryCard(
                        consumed: viewModel.consumedCalories,
                        goal: viewModel.dailyGoalCalories
                    )
                    
                    // Single macros section
                    MacrosSectionView()
                        .environmentObject(viewModel)
                    
                    // Motivation card (always visible)
                    MotivationCardView()
                    
                    // Meal sections with ads interleaved
                    MealSectionView(
                        meal: .breakfast,
                        items: viewModel.meals[.breakfast] ?? [],
                        onAddFoodTap: {
                            addFoodMeal = .breakfast
                            isShowingAddFood = true
                        },
                        onDelete: { item in
                            viewModel.remove(item, from: .breakfast)
                        }
                    )
                    
                    if viewModel.showAds {
                        AdCardView(model: AdCardView.sampleAds[0])
                    }
                    
                    MealSectionView(
                        meal: .lunch,
                        items: viewModel.meals[.lunch] ?? [],
                        onAddFoodTap: {
                            addFoodMeal = .lunch
                            isShowingAddFood = true
                        },
                        onDelete: { item in
                            viewModel.remove(item, from: .lunch)
                        }
                    )
                    
                    if viewModel.showAds {
                        AdCardView(model: AdCardView.sampleAds[1])
                    }
                    
                    MealSectionView(
                        meal: .dinner,
                        items: viewModel.meals[.dinner] ?? [],
                        onAddFoodTap: {
                            addFoodMeal = .dinner
                            isShowingAddFood = true
                        },
                        onDelete: { item in
                            viewModel.remove(item, from: .dinner)
                        }
                    )
                    
                    if viewModel.showAds {
                        AdCardView(model: AdCardView.sampleAds[2])
                    }
                    
                    MealSectionView(
                        meal: .snacks,
                        items: viewModel.meals[.snacks] ?? [],
                        onAddFoodTap: {
                            addFoodMeal = .snacks
                            isShowingAddFood = true
                        },
                        onDelete: { item in
                            viewModel.remove(item, from: .snacks)
                        }
                    )
                    
                    // No ad after snacks per spec
                    
                    Spacer(minLength: 120) // breathing room above tab bar + FAB
                }
                .padding(.horizontal, AppSpace.s16)
                .padding(.bottom, AppSpace.s16)
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
}

#Preview {
    TodayScreen()
        .environmentObject(TodayViewModel())
}
