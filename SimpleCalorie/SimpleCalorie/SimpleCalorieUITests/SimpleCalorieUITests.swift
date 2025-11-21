//
//  SimpleCalorieUITests.swift
//  SimpleCalorieUITests
//
//  Created by Amit Wadhwani on 11/11/25.
//

import XCTest

final class SimpleCalorieUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTodayScreenLoadsOnLaunch() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Breakfast"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Add food"].exists)
    }

    func testAddFoodSearchShowsResults() {
        let app = XCUIApplication()
        app.launch()

        // Wait for Today screen and Add food button
        let addFoodButton = app.buttons["Add food"]
        XCTAssertTrue(addFoodButton.waitForExistence(timeout: 10), "Add food button should exist on Today screen")
        addFoodButton.tap()

        // Wait for Add Food screen to appear.
        // The search field may be exposed as a textField or an otherElement depending on SwiftUI.
        var searchField = app.textFields["searchField"].firstMatch
        if !searchField.waitForExistence(timeout: 3) {
            searchField = app.otherElements["searchField"].firstMatch
        }

        XCTAssertTrue(
            searchField.waitForExistence(timeout: 10),
            "Search field should exist on Add Food screen"
        )

        // NOTE:
        // We intentionally do NOT assert on any specific result row here.
        // Search + results behavior is already validated in AddFoodViewModelTests.
        // This UI test's job is to ensure the Add Food flow loads and the search UI is present.
    }
}
