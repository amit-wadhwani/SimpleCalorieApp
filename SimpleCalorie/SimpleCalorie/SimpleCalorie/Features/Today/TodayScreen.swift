import SwiftUI

struct TodayScreen: View {
    @State private var showAddFood: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpace.s16) {
                        AppHeader()

                        CaloriesBlock(consumed: 1320, goal: 1800)

                        // "MACROS" label
                        Text("MACROS")
                            .font(AppFont.labelCapsSm())
                            .foregroundStyle(AppColor.textMuted)
                            .padding(.horizontal, AppSpace.s16)
                            .padding(.top, AppSpace.s12)

                        VStack(spacing: AppSpace.sm) {
                            MacroRow(
                                label: "Protein",
                                value: 45,
                                goal: 135,
                                color: AppColor.macroProtein
                            )

                            MacroRow(
                                label: "Carbs",
                                value: 120,
                                goal: 225,
                                color: AppColor.macroCarbs
                            )

                            MacroRow(
                                label: "Fat",
                                value: 28,
                                goal: 60,
                                color: AppColor.macroFat
                            )
                        }
                        .padding(.bottom, AppSpace.s12)

                        TipCard(text: "If you ate like this every day... You'd lose 1.2 lbs/week")

                        VStack(spacing: AppSpace.s12) {
                            MealCard(
                                title: "Breakfast",
                                kcal: 245,
                                items: ["Oatmeal with berries", "Black coffee"],
                                onAddFood: { showAddFood = true }
                            )

                            MealCard(
                                title: "Lunch",
                                kcal: 430,
                                items: ["Grilled chicken salad", "Apple"],
                                onAddFood: { showAddFood = true }
                            )

                            MealCard(
                                title: "Dinner",
                                kcal: 150,
                                items: ["Greek yogurt"],
                                onAddFood: { showAddFood = true }
                            )

                            MealCard(
                                title: "Snacks",
                                kcal: 0,
                                items: ["No items yet"],
                                onAddFood: { showAddFood = true }
                            )
                        }

                        Spacer(minLength: AppSpace.s24)
                    }
                    .padding(.vertical, AppSpace.s16)
                }

                FloatingAddButton {
                    showAddFood = true
                }
            }
            .navigationDestination(isPresented: $showAddFood) {
                AddFoodView(viewModel: AddFoodViewModel(service: MockFoodSearchService()))
            }
            .background(AppColor.bgScreen.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    TodayScreen()
}

