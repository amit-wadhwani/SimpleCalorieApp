# Test Implementation Summary

## Branch: `codex/today-quickadd-macros-tests`

## Overview
This branch adds comprehensive unit tests for Today Quick Add (suggestions-only, vertical layout) and Macros + calories behavior when suggestions or Copy From Date are used. All tests are deterministic using fixed GMT calendar and dates.

## Test File: `TodayQuickAddTests.swift`

### Tests Implemented

1. **`testRelativeSourcesAndAvailabilityFlags`**
   - Seeds repository with yesterday + last week breakfast, dinner, and snacks items
   - Creates TodayViewModel for fixed date (2024-01-08, GMT calendar)
   - Verifies availability flags (`hasYesterdayBreakfast`, `hasLastWeekBreakfast`, etc.)
   - Verifies source item retrieval methods return correct items
   - ✅ **UserDefaults cleanup**: Clears `"today.selectedDate"` before creating view model

2. **`testHandleMealSuggestionCopiesExpectedItems`**
   - Tests all 8 `MealSuggestion` cases:
     - `.yesterdayBreakfast`, `.lastWeekBreakfast`
     - `.yesterdayLunch`, `.lastNightDinner` (for lunch)
     - `.yesterdayDinner`, `.lastWeekDinner`
     - `.yesterdaySnacks`, `.lastWeekSnacks`
   - For each scenario:
     - Seeds a single source item on appropriate date/meal
     - Clears UserDefaults
     - Creates TodayViewModel for fixed date
     - Calls `handleMealSuggestion(_:)`
     - Verifies target meal contains the seeded items
     - Verifies total calories match
   - ✅ **UserDefaults cleanup**: Clears `"today.selectedDate"` in each scenario

3. **`testHandleMealSuggestionUpdatesMacros`**
   - Seeds yesterday breakfast with item containing protein, carbs, and fat
   - Clears UserDefaults
   - Creates TodayViewModel and calls `.handleMealSuggestion(.yesterdayBreakfast)`
   - Verifies:
     - `viewModel.meals.breakfast` contains the item
     - `viewModel.protein`, `viewModel.carbs`, `viewModel.fat`, and `viewModel.consumedCalories` match the item
   - ✅ **UserDefaults cleanup**: Clears `"today.selectedDate"` before creating view model

4. **`testCopyFromDatePreviewAndConfirmation`**
   - Seeds sourceDate (2 days before today) with two breakfast items
   - Creates TodayViewModel for today
   - Sets:
     - `copyFromDateSelectedDate = sourceDate`
     - `copyFromDateDestinationMealKind = .breakfast`
     - `copyFromDateSourceMealKind = .breakfast`
   - Verifies:
     - `previewItemsForCopyFromDate` returns seeded items in same order
     - `previewTotalCaloriesForCopyFromDate` is sum of items' calories
     - `canConfirmCopyFromDate` is true when source date is valid
   - Then sets `copyFromDateSelectedDate = today` and verifies:
     - `canConfirmCopyFromDate` is false
     - `previewItemsForCopyFromDate` is empty
   - ✅ **UserDefaults cleanup**: Clears `"today.selectedDate"` before creating view model

5. **`testHasItemsAndFirstMealKindHelpers`**
   - Tests three scenarios:
     - Repo with only breakfast items for today
     - Repo with only dinner items for today
     - Empty repo
   - For each:
     - Creates TodayViewModel for today
     - Verifies `hasItems(on:today, mealKind:...)` returns correct booleans
     - Verifies `firstMealKindWithItems(on:today)` returns `.breakfast`, `.dinner`, or `nil` accordingly
   - ✅ **UserDefaults cleanup**: Clears `"today.selectedDate"` before creating view models

6. **`testConfirmCopyFromDateUpdatesMacrosAndCalories`**
   - Seeds sourceDate (3 days before today) with single dinner item containing macros
   - Creates TodayViewModel for today
   - Sets:
     - `copyFromDateDestinationMealKind = .lunch`
     - `copyFromDateSourceMealKind = .dinner`
     - `copyFromDateSelectedDate = sourceDate`
   - Calls `viewModel.confirmCopyFromDate()`
   - Verifies:
     - `viewModel.meals.lunch` contains the dinner item
     - `viewModel.protein`, `viewModel.carbs`, `viewModel.fat`, and `viewModel.consumedCalories` match the item

## Deterministic Date/Time Behavior

- All tests use fixed GMT calendar: `Calendar(identifier: .gregorian)` with `TimeZone(secondsFromGMT: 0)!`
- All dates created via `makeDate(year:month:day:)` helper using fixed calendar
- No reliance on `Date()` or system timezones in tests
- Production code paths used in tests don't pull in `Date()` during test execution

## UserDefaults Hygiene

All tests that depend on `TodayViewModel.selectedDate` behavior clear persisted values:
- `testRelativeSourcesAndAvailabilityFlags` ✅
- `testHandleMealSuggestionCopiesExpectedItems` ✅ (in each scenario)
- `testHandleMealSuggestionUpdatesMacros` ✅
- `testCopyFromDatePreviewAndConfirmation` ✅
- `testHasItemsAndFirstMealKindHelpers` ✅

## UI Tests: `TodayQuickAddUITests.swift`

### Tests Updated

1. **`testSmartSuggestionsVisibilityAndHideAfterAddingFood`**
   - ✅ **Removed**: `setQuickAddMode("Suggestions", app: app)` call
   - Suggestions are always on now (no mode picker exists)
   - Test verifies suggestions appear for empty meals and hide after adding food
   - **Status**: ✅ PASSING

2. **`testCopyFromDateSheetPreviewAndCopy`**
   - ✅ **Removed**: `setQuickAddMode("Suggestions", app: app)` call
   - Test verifies "Copy from Date…" chip is visible for empty breakfast
   - Intentionally minimal - doesn't test sheet opening or copy behavior (covered by unit tests)
   - **Status**: ✅ PASSING

3. **`testSwipeQuickAddVisibleOnlyWhenEmpty`**
   - ✅ **Marked as skipped**: Swipe-based quick add has been removed
   - Uses `XCTSkip` with clear message explaining why
   - **Status**: ✅ SKIPPED (as intended)

### Removed Helper

- **`setQuickAddMode(_:app:)`**: Removed entirely - Quick Add mode picker no longer exists in Settings

## Production Code Changes

### Minimal Changes Made

1. **`TodayQuickAddTests.swift`**
   - Added `copyFromDateDestinationMealKind` to `testCopyFromDatePreviewAndConfirmation` (was missing)
   - Added UserDefaults cleanup to `testHasItemsAndFirstMealKindHelpers` (was missing)

2. **`TodayQuickAddUITests.swift`**
   - Removed all references to Quick Add mode picker (no longer exists)
   - Marked swipe test as skipped with `XCTSkip`

### No Behavior Reintroduced

✅ **Verified**: No old behavior has been reintroduced:
- ✅ Quick Add is suggestions-only, vertical layout (fixed)
- ✅ Swipe-based quick add remains removed
- ✅ Macros style is fixed to Capsule + Goals (no user setting)

## Test Results

### Unit Tests (`SimpleCalorieTests`)
- ✅ All 6 `TodayQuickAddTests` tests passing
- ✅ All other existing unit tests still passing (no regressions)

### UI Tests (`SimpleCalorieUITests`)
- ✅ `testSmartSuggestionsVisibilityAndHideAfterAddingFood` passing
- ✅ `testCopyFromDateSheetPreviewAndCopy` passing
- ✅ `testSwipeQuickAddVisibleOnlyWhenEmpty` skipped (as intended)
- ✅ All other existing UI tests still passing (no regressions)

## Summary

All tests are implemented, deterministic, and passing. The test suite comprehensively covers:
- Quick Add suggestions behavior (all 8 meal suggestion types)
- Copy From Date preview and confirmation logic
- Macro and calorie updates when copying items
- Availability flags and source item retrieval
- Helper methods for checking meal item existence

No production code changes were needed beyond the minimal fixes to match the test expectations. All tests use fixed dates and GMT calendar for determinism.

