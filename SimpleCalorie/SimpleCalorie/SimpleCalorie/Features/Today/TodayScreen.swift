import SwiftUI

struct TodayScreen: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @State private var isShowingDatePicker = false
    @State private var isShowingAddFood: Bool = false
    @State private var addFoodMeal: MealType = .breakfast
    @State private var showSettingsMenu: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Sticky header
            TodayHeaderView(
                selectedDate: $viewModel.selectedDate,
                consumedCalories: viewModel.consumedCalories,
                dailyGoalCalories: viewModel.dailyGoalCalories,
                onDateTap: { isShowingDatePicker = true },
                onSettingsTap: { showSettingsMenu = true }
            )

            Divider().opacity(0)  // maintains spacing but keeps header visually clean

            // Scrollable content
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: AppSpace.s16) {
                        MotivationCardView()

                        ForEach(MealType.allCases) { meal in
                            MealSectionView(
                                meal: meal,
                                items: viewModel.meals[meal] ?? [],
                                onAddFoodTap: {
                                    addFoodMeal = meal
                                    isShowingAddFood = true
                                }
                            )
                        }

                        ForEach(AdCardView.sampleAds) { ad in
                            AdCardView(model: ad)
                        }

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
        .sheet(isPresented: $showSettingsMenu) {
            NavigationStack {
                VStack(alignment: .leading, spacing: AppSpace.s16) {
                    Toggle(isOn: .constant(true)) {
                        Label("Show Sponsored Tips", systemImage: "eye")
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showSettingsMenu = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TodayScreen()
        .environmentObject(TodayViewModel())
}
