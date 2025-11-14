import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @State private var isShowingDatePicker = false
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType = .breakfast

    var body: some View {
        VStack(spacing: 0) {
            // Sticky header
            TodayHeaderView(
                selectedDate: $viewModel.selectedDate,
                consumedCalories: viewModel.consumedCalories,
                dailyGoalCalories: viewModel.dailyGoalCalories,
                onDateTap: { isShowingDatePicker = true }
            )

            Divider().opacity(0)  // maintains spacing but keeps header visually clean

            // Scrollable content
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: AppSpace.s16) {
                        MotivationCardView()

                        // Interleave meals and ads
                        MealSectionView(
                            meal: .breakfast,
                            items: viewModel.meals[.breakfast] ?? [],
                            onAddFoodTap: {
                                addFoodMeal = .breakfast
                                isShowingAddFood = true
                            }
                        )
                        
                        AdCardView(model: AdCardView.sampleAds[0])

                        MealSectionView(
                            meal: .lunch,
                            items: viewModel.meals[.lunch] ?? [],
                            onAddFoodTap: {
                                addFoodMeal = .lunch
                                isShowingAddFood = true
                            }
                        )
                        
                        AdCardView(model: AdCardView.sampleAds[1])

                        MealSectionView(
                            meal: .dinner,
                            items: viewModel.meals[.dinner] ?? [],
                            onAddFoodTap: {
                                addFoodMeal = .dinner
                                isShowingAddFood = true
                            }
                        )
                        
                        AdCardView(model: AdCardView.sampleAds[2])

                        MealSectionView(
                            meal: .snacks,
                            items: viewModel.meals[.snacks] ?? [],
                            onAddFoodTap: {
                                addFoodMeal = .snacks
                                isShowingAddFood = true
                            }
                        )
                        
                        AdCardView(model: AdCardView.sampleAds[3])

                        Spacer(minLength: AppSpace.s24)
                    }
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.top, AppSpace.s16)
                    .padding(.bottom, 80)
                }

                FloatingAddButton {
                    addFoodMeal = .breakfast
                    isShowingAddFood = true
                }
                .padding(.trailing, AppSpace.s24)
                .padding(.bottom, 80)
            }
        }
        .background(AppColor.bgScreen.ignoresSafeArea())
        .sheet(isPresented: $isShowingDatePicker) {
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
