import SwiftUI

struct TodayScreen: View {
    @State private var showAddFood = false
    
    // Demo data matching Figma
    @State private var calories = CalorieSummary(consumed: 1320, target: 1800)
    @State private var macros   = MacroSummary(
        protein: (45, 135),
        carbs:   (120, 225),
        fat:     (28, 60)
    )

    @State private var meals: [MealType: [FoodEntry]] = [
        .breakfast: [
            FoodEntry(name: "Oatmeal with berries", calories: 240),
            FoodEntry(name: "Black coffee", calories: 5)
        ],
        .lunch: [
            FoodEntry(name: "Grilled chicken salad", calories: 350),
            FoodEntry(name: "Apple", calories: 80)
        ],
        .dinner: [
            FoodEntry(name: "Greek yogurt", calories: 150)
        ],
        .snacks: []
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpace.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpace.md) {
                        HStack(spacing: AppSpace.sm) {
                            Text("SimpleCalorie")
                                .font(AppFont.title())
                                .foregroundStyle(AppColor.textTitle)
                            Spacer()
                            // Profile icon with settings
                            HStack(spacing: AppSpace.sm) {
                                Circle()
                                    .fill(AppColor.brandPrimary.opacity(0.12))
                                    .frame(width: 28, height: 28)
                                    .overlay(Text("JD").font(.system(size: 11)).foregroundStyle(AppColor.brandPrimary))
                                Image(systemName: "gearshape")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppColor.textMuted)
                            }
                        }
                        Text(formattedToday())
                            .font(AppFont.bodySmSmall())
                            .foregroundStyle(AppColor.textMuted)

                        CalorieBar(summary: calories)
                    }

                    // Macros
                    VStack(alignment: .leading, spacing: AppSpace.md) {
                        Text("MACROS")
                            .font(AppFont.section())
                            .foregroundStyle(AppColor.textTitle)

                        VStack(spacing: AppSpace.md) {
                            MacroBar(kind: .protein, current: macros.protein.current, target: macros.protein.target)
                            MacroBar(kind: .carbs,   current: macros.carbs.current,   target: macros.carbs.target)
                            MacroBar(kind: .fat,     current: macros.fat.current,     target: macros.fat.target)
                        }
                    }

                    // Tip card
                    TipCard(emoji: "💡", text: "If you ate like this every day... You'd lose 1.2 lbs/week")

                    // Meals
                    VStack(alignment: .leading, spacing: AppSpace.xl) {
                        ForEach(MealType.allCases) { meal in
                            MealSectionCard(
                                meal: meal,
                                items: meals[meal] ?? [],
                                onAdd: {
                                    showAddFood = true
                                }
                            )
                        }
                    }

                    Spacer(minLength: AppSpace.xxl)
                }
                .padding(.horizontal, AppSpace.xl)
                .padding(.top, AppSpace.xl)
            }
            .background(AppColor.bgScreen.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Today")
                        .font(AppFont.title())
                        .foregroundStyle(AppColor.textTitle)
                }
            }
            .navigationDestination(isPresented: $showAddFood) {
                AddFoodView(viewModel: AddFoodViewModel(service: MockFoodSearchService()))
            }
        }
    }

    private func formattedToday() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: .now)
    }
}

#Preview {
    TodayScreen()
}

