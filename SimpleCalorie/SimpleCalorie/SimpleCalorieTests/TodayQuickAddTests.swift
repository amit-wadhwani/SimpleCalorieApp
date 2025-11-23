import XCTest
@testable import SimpleCalorie

@MainActor
final class TodayQuickAddTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    private func seededRepository(for today: Date) -> InMemoryFoodRepository {
        let repo = InMemoryFoodRepository()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!

        _ = repo.add(FoodItem(name: "Yesterday Breakfast", calories: 320, description: "1 bowl"), to: .breakfast, on: yesterday)
        _ = repo.add(FoodItem(name: "Last Week Breakfast", calories: 280, description: "1 bowl"), to: .breakfast, on: lastWeek)
        _ = repo.add(FoodItem(name: "Yesterday Lunch", calories: 410, description: "1 plate"), to: .lunch, on: yesterday)
        _ = repo.add(FoodItem(name: "Last Night Dinner", calories: 525, description: "1 plate"), to: .dinner, on: yesterday)
        _ = repo.add(FoodItem(name: "Yesterday Dinner", calories: 600, description: "1 plate"), to: .dinner, on: yesterday)
        _ = repo.add(FoodItem(name: "Last Week Dinner", calories: 455, description: "1 plate"), to: .dinner, on: lastWeek)
        _ = repo.add(FoodItem(name: "Yesterday Snacks", calories: 220, description: "1 bar"), to: .snacks, on: yesterday)
        _ = repo.add(FoodItem(name: "Last Week Snacks", calories: 180, description: "1 bar"), to: .snacks, on: lastWeek)

        return repo
    }

    func testRelativeSourcesAndAvailabilityFlags() {
        let today = makeDate(year: 2024, month: 1, day: 8)
        let repo = seededRepository(for: today)

        UserDefaults.standard.removeObject(forKey: "today.selectedDate")
        let viewModel = TodayViewModel(repo: repo, date: today, seedDemoData: false)

        XCTAssertTrue(viewModel.hasYesterdayBreakfast)
        XCTAssertTrue(viewModel.hasLastWeekBreakfast)
        XCTAssertTrue(viewModel.hasYesterdayLunch)
        XCTAssertTrue(viewModel.hasLastNightDinnerForLunch)
        XCTAssertTrue(viewModel.hasYesterdayDinner)
        XCTAssertTrue(viewModel.hasLastWeekDinner)
        XCTAssertTrue(viewModel.hasYesterdaySnacks)
        XCTAssertTrue(viewModel.hasLastWeekSnacks)

        let breakfastYesterday = viewModel.sourceItemsForYesterday(mealKind: .breakfast)
        let breakfastLastWeek = viewModel.sourceItemsForLastWeek(mealKind: .breakfast)
        let dinnerLastNight = viewModel.sourceItemsForLastNightDinner()

        XCTAssertEqual(breakfastYesterday.count, 1)
        XCTAssertEqual(breakfastYesterday.first?.name, "Yesterday Breakfast")
        XCTAssertEqual(breakfastLastWeek.count, 1)
        XCTAssertEqual(breakfastLastWeek.first?.name, "Last Week Breakfast")
        XCTAssertEqual(dinnerLastNight.first?.name, "Last Night Dinner")
    }

    func testHandleMealSuggestionCopiesExpectedItems() {
        let today = makeDate(year: 2024, month: 1, day: 8)

        let scenarios: [(TodayViewModel.MealSuggestion, MealType, (InMemoryFoodRepository) -> [FoodItem])] = [
            (.yesterdayBreakfast, .breakfast, { repo in
                let yesterday = self.calendar.date(byAdding: .day, value: -1, to: today)!
                let item = FoodItem(name: "Copy Oats", calories: 250, description: "1 bowl")
                _ = repo.add(item, to: .breakfast, on: yesterday)
                return [item]
            }),
            (.lastWeekBreakfast, .breakfast, { repo in
                let lastWeek = self.calendar.date(byAdding: .day, value: -7, to: today)!
                let item = FoodItem(name: "Copy Toast", calories: 190, description: "2 slices")
                _ = repo.add(item, to: .breakfast, on: lastWeek)
                return [item]
            }),
            (.yesterdayLunch, .lunch, { repo in
                let yesterday = self.calendar.date(byAdding: .day, value: -1, to: today)!
                let item = FoodItem(name: "Copy Salad", calories: 340, description: "1 bowl")
                _ = repo.add(item, to: .lunch, on: yesterday)
                return [item]
            }),
            (.lastNightDinner, .lunch, { repo in
                let yesterday = self.calendar.date(byAdding: .day, value: -1, to: today)!
                let item = FoodItem(name: "Copy Pasta", calories: 480, description: "1 plate")
                _ = repo.add(item, to: .dinner, on: yesterday)
                return [item]
            }),
            (.yesterdayDinner, .dinner, { repo in
                let yesterday = self.calendar.date(byAdding: .day, value: -1, to: today)!
                let item = FoodItem(name: "Copy Steak", calories: 520, description: "1 plate")
                _ = repo.add(item, to: .dinner, on: yesterday)
                return [item]
            }),
            (.lastWeekDinner, .dinner, { repo in
                let lastWeek = self.calendar.date(byAdding: .day, value: -7, to: today)!
                let item = FoodItem(name: "Copy Fish", calories: 410, description: "1 plate")
                _ = repo.add(item, to: .dinner, on: lastWeek)
                return [item]
            }),
            (.yesterdaySnacks, .snacks, { repo in
                let yesterday = self.calendar.date(byAdding: .day, value: -1, to: today)!
                let item = FoodItem(name: "Copy Bar", calories: 180, description: "1 bar")
                _ = repo.add(item, to: .snacks, on: yesterday)
                return [item]
            }),
            (.lastWeekSnacks, .snacks, { repo in
                let lastWeek = self.calendar.date(byAdding: .day, value: -7, to: today)!
                let item = FoodItem(name: "Copy Nuts", calories: 160, description: "1 pack")
                _ = repo.add(item, to: .snacks, on: lastWeek)
                return [item]
            })
        ]

        for (suggestion, meal, seed) in scenarios {
            let repo = InMemoryFoodRepository()
            let expectedItems = seed(repo)
            UserDefaults.standard.removeObject(forKey: "today.selectedDate")
            let viewModel = TodayViewModel(repo: repo, date: today, seedDemoData: false)

            viewModel.handleMealSuggestion(suggestion)

            let mealItems = viewModel.meals.items(for: meal)
            XCTAssertEqual(mealItems, expectedItems)
            XCTAssertEqual(viewModel.totalCalories(for: meal), expectedItems.reduce(0) { $0 + $1.calories })
        }
    }

    func testCopyFromDatePreviewAndConfirmation() {
        let today = makeDate(year: 2024, month: 1, day: 8)
        let sourceDate = calendar.date(byAdding: .day, value: -2, to: today)!
        let repo = InMemoryFoodRepository()
        let itemA = FoodItem(name: "Preview Oats", calories: 200, description: "1 bowl")
        let itemB = FoodItem(name: "Preview Tea", calories: 5, description: "1 cup")
        _ = repo.add(itemA, to: .breakfast, on: sourceDate)
        _ = repo.add(itemB, to: .breakfast, on: sourceDate)

        let viewModel = TodayViewModel(repo: repo, date: today, seedDemoData: false)
        viewModel.copyFromDateSelectedDate = sourceDate
        viewModel.copyFromDateTargetMealKind = .breakfast

        XCTAssertEqual(viewModel.previewItemsForCopyFromDate, [itemA, itemB])
        XCTAssertEqual(viewModel.previewTotalCaloriesForCopyFromDate, itemA.calories + itemB.calories)
        XCTAssertTrue(viewModel.canConfirmCopyFromDate)

        viewModel.copyFromDateSelectedDate = today
        XCTAssertFalse(viewModel.canConfirmCopyFromDate)
        XCTAssertEqual(viewModel.previewItemsForCopyFromDate.count, 0)
    }

    func testHasItemsAndFirstMealKindHelpers() {
        let today = makeDate(year: 2024, month: 1, day: 9)

        let breakfastOnlyRepo = InMemoryFoodRepository()
        _ = breakfastOnlyRepo.add(FoodItem(name: "Only Breakfast", calories: 300, description: "1 bowl"), to: .breakfast, on: today)
        let breakfastViewModel = TodayViewModel(repo: breakfastOnlyRepo, date: today, seedDemoData: false)

        XCTAssertTrue(breakfastViewModel.hasItems(on: today, mealKind: .breakfast))
        XCTAssertFalse(breakfastViewModel.hasItems(on: today, mealKind: .lunch))
        XCTAssertEqual(breakfastViewModel.firstMealKindWithItems(on: today), .breakfast)

        let dinnerOnlyRepo = InMemoryFoodRepository()
        _ = dinnerOnlyRepo.add(FoodItem(name: "Only Dinner", calories: 500, description: "1 plate"), to: .dinner, on: today)
        let dinnerViewModel = TodayViewModel(repo: dinnerOnlyRepo, date: today, seedDemoData: false)

        XCTAssertFalse(dinnerViewModel.hasItems(on: today, mealKind: .breakfast))
        XCTAssertTrue(dinnerViewModel.hasItems(on: today, mealKind: .dinner))
        XCTAssertEqual(dinnerViewModel.firstMealKindWithItems(on: today), .dinner)

        let emptyViewModel = TodayViewModel(repo: InMemoryFoodRepository(), date: today, seedDemoData: false)
        XCTAssertNil(emptyViewModel.firstMealKindWithItems(on: today))
    }
}
