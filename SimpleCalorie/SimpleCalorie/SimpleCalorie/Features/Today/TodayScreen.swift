import SwiftUI

struct TodayScreen: View {
    @State private var showAddFood: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpace.s16) {
                        AppHeader()

                        CaloriesBlock(consumed: 1320, goal: 1800)

                        // "MACROS" label
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MACROS")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(0.5)
                                .foregroundStyle(AppColor.textMuted)
                                .padding(.horizontal, AppSpace.s16)

                            VStack(alignment: .leading, spacing: 12) {
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
                        }
                        .padding(.vertical, AppSpace.s16)

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
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.top, AppSpace.s16)
                    .padding(.bottom, AppSpace.s24)
                }

                FloatingAddButton {
                    showAddFood = true
                }
                .padding(.trailing, AppSpace.s24)
                .padding(.bottom, AppSpace.s24)
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

