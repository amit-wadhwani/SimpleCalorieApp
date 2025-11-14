import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @AppStorage("showAds") private var showAds: Bool = true
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType = .breakfast

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            AppColor.bgScreen
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section: date + total calories + macros (single copy)
                VStack(spacing: AppSpace.s16) {
                    TodayHeaderView(
                        selectedDate: $viewModel.selectedDate,
                        onDateTap: {
                            viewModel.isDatePickerPresented = true
                        }
                    )
                    .environmentObject(viewModel)
                    
                    CalorieSummaryCard(
                        consumed: viewModel.consumedCalories,
                        goal: viewModel.dailyGoalCalories
                    )
                    
                    MacrosSectionView()
                        .environmentObject(viewModel)
                }
                .padding(.horizontal, AppSpace.s16)
                .padding(.top, AppSpace.s16)
                .padding(.bottom, AppSpace.s12)
                
                // Scrollable content: motivation + meals + ads
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpace.s16) {
                        MotivationCardView()
                            .padding(.horizontal, AppSpace.s16)
                            .padding(.top, AppSpace.s16)
                        
                        // Interleave meals and ads
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
                        .padding(.horizontal, AppSpace.s16)
                        
                        if showAds {
                            AdCardView(model: AdCardView.sampleAds[0])
                                .padding(.horizontal, AppSpace.s16)
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
                        .padding(.horizontal, AppSpace.s16)
                        
                        if showAds {
                            AdCardView(model: AdCardView.sampleAds[1])
                                .padding(.horizontal, AppSpace.s16)
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
                        .padding(.horizontal, AppSpace.s16)
                        
                        if showAds {
                            AdCardView(model: AdCardView.sampleAds[2])
                                .padding(.horizontal, AppSpace.s16)
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
                        .padding(.horizontal, AppSpace.s16)
                        
                        if showAds {
                            AdCardView(model: AdCardView.sampleAds[3])
                                .padding(.horizontal, AppSpace.s16)
                        }
                        
                        Spacer(minLength: 120) // breathing room above tab bar + FAB
                    }
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
}

#Preview {
    TodayScreen()
        .environmentObject(TodayViewModel())
}
