import XCTest
@testable import SimpleCalorie

final class MacroInfoTests: XCTestCase {
    func testCaloriesEstimateUsesMacroMultipliers() {
        let macros = MacroInfo(protein: 30, carbs: 45, fat: 10)
        // 30*4 + 45*4 + 10*9 = 120 + 180 + 90 = 390
        XCTAssertEqual(macros.caloriesEstimate, 390)
    }

    func testCaloriesEstimateRoundsToNearestInt() {
        let macros = MacroInfo(protein: 12.5, carbs: 20.2, fat: 5.4)
        let expected = ((12.5 * 4) + (20.2 * 4) + (5.4 * 9)).rounded()
        XCTAssertEqual(macros.caloriesEstimate, Int(expected))
    }
}
