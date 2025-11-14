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
                    HStack {
                        Spacer()
                        
                        HStack(spacing: AppSpace.s16) {
                            Button {
                                viewModel.goToPreviousDay()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColor.brandPrimary)
                            }
                            
                            Button {
                                viewModel.isDatePickerPresented = true
                            } label: {
                                Text(formattedDate())
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AppColor.textTitle)
                            }
                            
                            Button {
                                viewModel.goToNextDay()
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColor.brandPrimary)
                            }
                        }
                        .foregroundStyle(AppColor.textTitle)
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    }
                    .padding(.horizontal, AppSpace.s16)
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
                
                // 2) Scrollable zone: meals + ads + everything else
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpace.s16) {
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
                    .padding(.vertical, AppSpace.s16)
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
