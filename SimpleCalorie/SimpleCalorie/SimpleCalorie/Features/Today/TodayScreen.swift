import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @AppStorage("showAds") private var showAds: Bool = true
    @State private var isShowingDatePicker = false
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType = .breakfast

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: AppSpace.s16, pinnedViews: [.sectionHeaders]) {
                    Section {
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

                        Spacer(minLength: AppSpace.s24)
                    } header: {
                        TodayHeaderView(
                            selectedDate: $viewModel.selectedDate,
                            consumedCalories: viewModel.consumedCalories,
                            dailyGoalCalories: viewModel.dailyGoalCalories,
                            onDateTap: { isShowingDatePicker = true }
                        )
                        .environmentObject(viewModel)
                        .background(
                            Material.ultraThinMaterial
                        )
                        .overlay(
                            Divider().offset(y: 1),
                            alignment: .bottom
                        )
                    }
                }
                .padding(.bottom, 80)
            }

            FloatingAddButton {
                addFoodMeal = .breakfast
                isShowingAddFood = true
            }
            .padding(.trailing, AppSpace.s24)
            .padding(.bottom, 80)
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
