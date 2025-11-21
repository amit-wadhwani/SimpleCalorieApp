//
//  SimpleCalorieTests.swift
//  SimpleCalorieTests
//
//  Created by Amit Wadhwani on 11/11/25.
//

import XCTest
@testable import SimpleCalorie

final class MealsModelTests: XCTestCase {
    func testItemsForMealReturnsExpectedList() {
        let breakfast = [FoodItem(name: "Oats", calories: 200, description: "1 cup")]
        let lunch = [FoodItem(name: "Salad", calories: 300, description: "bowl")]
        let meals = Meals(breakfast: breakfast, lunch: lunch, dinner: [], snacks: [])

        XCTAssertEqual(meals.items(for: .breakfast), breakfast)
        XCTAssertEqual(meals.items(for: .lunch), lunch)
        XCTAssertTrue(meals.items(for: .dinner).isEmpty)
        XCTAssertTrue(meals.items(for: .snacks).isEmpty)
    }

    func testAllItemsAggregatesEveryMeal() {
        let meals = Meals(
            breakfast: [FoodItem(name: "Oats", calories: 200, description: "1 cup")],
            lunch: [FoodItem(name: "Salad", calories: 300, description: "bowl")],
            dinner: [FoodItem(name: "Soup", calories: 180, description: "cup")],
            snacks: [FoodItem(name: "Apple", calories: 95, description: "1 medium")]
        )

        XCTAssertEqual(meals.allItems.count, 4)
        XCTAssertEqual(meals.allItems.map { $0.name }, ["Oats", "Salad", "Soup", "Apple"])
    }
}
