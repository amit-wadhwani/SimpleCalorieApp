import SwiftUI

struct TodayScreen: View {
    @State private var showAddFood: Bool = false
    @State private var activeMealForAddFood: MealType = .breakfast
    @State private var currentDate: Date = Date()
    @State private var showSponsoredCards: Bool = true
    @State private var showSettingsMenu: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpace.s16) {
                        AppHeader(currentDate: $currentDate) {
                            showSettingsMenu = true
                        }

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
                                title: MealType.breakfast.displayName,
                                kcal: 245,
                                items: ["Oatmeal with berries", "Black coffee"],
                                onAddFood: {
                                    activeMealForAddFood = .breakfast
                                    showAddFood = true
                                }
                            )

                            if showSponsoredCards {
                                SponsoredCardView(
                                    title: "Smart Tip: Try adding healthy fats to breakfast for better satiety.",
                                    isAd: false
                                )
                            }

                            MealCard(
                                title: MealType.lunch.displayName,
                                kcal: 430,
                                items: ["Grilled chicken salad", "Apple"],
                                onAddFood: {
                                    activeMealForAddFood = .lunch
                                    showAddFood = true
                                }
                            )

                            if showSponsoredCards {
                                SponsoredCardView(
                                    title: "Simple Premium auto-logs your meals and macros.",
                                    isAd: true
                                )
                            }

                            MealCard(
                                title: MealType.dinner.displayName,
                                kcal: 150,
                                items: ["Greek yogurt"],
                                onAddFood: {
                                    activeMealForAddFood = .dinner
                                    showAddFood = true
                                }
                            )

                            if showSponsoredCards {
                                SponsoredCardView(
                                    title: "Smart Tip: High-protein dinners boost next-day energy.",
                                    isAd: false
                                )
                            }

                            MealCard(
                                title: MealType.snacks.displayName,
                                kcal: 0,
                                items: ["No items yet"],
                                onAddFood: {
                                    activeMealForAddFood = .snacks
                                    showAddFood = true
                                }
                            )

                            if showSponsoredCards {
                                SponsoredCardView(
                                    title: "New SimpleCalorie recipes — discover under 200-calorie snacks.",
                                    isAd: true
                                )
                            }
                        }

                        Spacer(minLength: AppSpace.s24)
                    }
                    .padding(.horizontal, AppSpace.s16)
                    .padding(.top, AppSpace.s16)
                    .padding(.bottom, 120) // Leave space for tab bar + FAB
                }

                FloatingAddButton {
                    activeMealForAddFood = .breakfast // Default to breakfast for FAB
                    showAddFood = true
                }
                .padding(.trailing, AppSpace.s24)
                .padding(.bottom, 80) // Position above tab bar
            }
            .sheet(isPresented: $showAddFood) {
                NavigationStack {
                    AddFoodView(
                        viewModel: AddFoodViewModel(service: MockFoodSearchService()),
                        initialMeal: activeMealForAddFood
                    )
                }
            }
            .sheet(isPresented: $showSettingsMenu) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: AppSpace.s16) {
                        Toggle(isOn: $showSponsoredCards) {
                            Label("Show Sponsored Tips", systemImage: showSponsoredCards ? "eye" : "eye.slash")
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
            .background(AppColor.bgScreen.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    TodayScreen()
}

