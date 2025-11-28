# AGENTS GUIDE — SimpleCalorie

This document is for automated coding agents (like OpenAI Codex) that work on this repo.

## Project Progress Tracking

**Project progress and plan are maintained in `docs/ProjectSpine.md`.**  
Update this file whenever you complete a significant phase, sub-phase, or add/remove active threads and parking-lot items. The spine serves as the canonical source of truth for project status and should be kept current with each major milestone.

## Tech Stack

- **Platform:** iOS, SwiftUI, iOS 17+
- **Language:** Swift 5+
- **Architecture:**
  - Root entry: `SimpleCalorieApp.swift`
  - App shell: `App/AppRootView.swift`
  - Feature structure:
    - `Features/Today` — Today screen, header, cards, meals
    - `Features/AddFood` — Search & add food flow
  - Shared UI:
    - `Core/UI` — generic UI components (cards, FAB, toast, haptics)
    - `Design` — design tokens (colors, spacing, radius, typography)
    - `Core/Models`, `Core/Data`, `Core/Preferences` — models & data/repo

## Design System

- **Colors:** defined in `Design/Colors.swift` and `Assets.xcassets`
  - Use `AppColor` helpers (e.g., `AppColor.bgScreen`, `AppColor.borderSubtle`, `AppColor.brandPrimary`)
- **Spacing:** `Design/Spacing.swift` via `AppSpace`
- **Radius:** `Design/Radius.swift` via `AppRadius`
- **Typography:** `Design/Typography.swift` via `AppTypography`

When adding UI, prefer:
- SwiftUI
- Existing tokens (`AppColor`, `AppSpace`, `AppRadius`, `AppTypography`)
- No Storyboards / XIBs.

## Building & Running

From the repo root:

- Open `SimpleCalorie.xcodeproj` or `SimpleCalorie.xcworkspace` in Xcode.
- Target: `SimpleCalorie` iOS app.
- Minimum iOS version: 17 (assumed; keep APIs compatible with that).

Automated agents should **not** change project settings or bundle identifiers.

## Tests

We now have a small but growing test suite: `SimpleCalorieTests` for unit tests and `SimpleCalorieUITests` for UI smoke tests.

- If you add tests, use XCTest:
  - Test target names like `SimpleCalorieTests` (or create if missing).
  - Put tests under `SimpleCalorieTests/` with `@testable import SimpleCalorie`.

## Today Screen Layout

- **Root:** `Features/Today/TodayRootView.swift`
- **Screen container:** `Features/Today/TodayScreen.swift`
- **Shared layout helpers:** `Features/Today/Common/TodayLayout.swift`
- **Cards:**
  - `Cards/CalorieSummaryCard.swift`
  - `Cards/MotivationCardView.swift`
  - `Cards/AdCardView.swift`
  - `Cards/DecorSpacerCard.swift` — visual spacer between sections
- **Meals list:** `Meals/MealSectionList.swift`

### Today Screen – Quick Add (Smart Suggestions + Swipe)

The Today screen supports two complementary "quick add" mechanisms for meals:

- **Smart Suggestions** – a row of subtle pills inside each meal card (Breakfast, Lunch, Dinner, Snacks) that offer:
  - Yesterday's <Meal> (shown only if data is available)
  - Last Week's <Meal> (Breakfast, Dinner, Snacks) / Last Night's Dinner (for Lunch) (shown only if data is available)
  - Copy from Date… (always shown)

- **Swipe Actions** – trailing swipe actions (right-to-left) on the meal cards with colored tiles:
  - Yesterday (shown only if data is available)
  - Last Week / Last Night (shown only if data is available)
  - Choose (Copy from Date…) (always shown)

**Important:** SmartSuggestionsRow and swipe actions are only shown when the meal is empty (no food items). Once items are added, quick add options are hidden.

These two behaviors are controlled by `TodayQuickAddMode`:
- `.suggestions` – show SmartSuggestionsRow only (default)
- `.swipe` – enable swipe actions only
- `.both` – show SmartSuggestionsRow and swipe actions

The mode is stored via `@AppStorage(TodayQuickAddMode.storageKey)` and can be changed from the Today Settings UI (Quick Add Style segmented control).

**Layout Mode:** SmartSuggestionsRow supports horizontal and vertical layouts, controlled by `TodaySuggestionsLayoutMode` (default: horizontal). This can be changed in Settings.

**Availability:** The view model exposes boolean properties (`hasYesterdayBreakfast`, `hasLastWeekBreakfast`, etc.) that gate which suggestions are visible. These are currently placeholders that return `true`; they will be implemented with actual data checks once persistence is in place.

When extending quick add behavior, agents should:
- Reuse `SmartSuggestionsRow` and swipe actions rather than reinventing UI.
- Route new behaviors through `TodayViewModel.handleMealSuggestion(_:)` and `presentCopyFromDatePicker(for:)`.
- Avoid hard-coding date logic in views; keep it in view models and data layers.
- Check availability booleans before showing suggestion chips/buttons.

### No-Ads Separator (current behavior)

- Today card sections are separated by a single, fixed “no-ads separator.”
- The separator is a subtle, centered capsule between cards (old-capsule look with tuned size).
- There are no runtime options for Invisible/Divider/New capsule; the canonical style is hard-coded.

## General Code Style

- Prefer small, focused SwiftUI views.
- Follow existing naming conventions.
- Avoid introducing external dependencies.
- Keep public APIs unchanged unless explicitly requested.

If in doubt about choices, prefer:
- Native iOS patterns (e.g., List swipe actions, sheets)
- Clear, readable code over cleverness.

## Tests & Workflow

- **Unit tests:**
  - Target: `SimpleCalorieTests`.
  - How to run:
    - In Xcode: select the `SimpleCalorie` scheme and press **Cmd+U**.
    - CLI example (requires macOS + Xcode):
      ```
      xcodebuild -scheme "SimpleCalorie" \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -only-testing:SimpleCalorieTests test
      ```
    - Simulator name can vary; adjust to an installed iOS 17+ simulator.
  - Expectation: after any code change, Codex/Cursor should run unit tests and ensure they pass.

- **UI tests:**
  - Target: `SimpleCalorieUITests` (smoke coverage for Today + Add Food flows).
  - How to run:
    - In Xcode: run via the Test navigator or **Cmd+U** with the UI test target included.
    - CLI example:
      ```
      xcodebuild -scheme "SimpleCalorie" \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -only-testing:SimpleCalorieUITests test
      ```
  - Expectation: UI tests are slower and **not** required on every change. Run them before important releases or when a task explicitly targets UI flows. If a change breaks UI tests, open/follow a dedicated task to repair and re-run them.

> Note: This Linux sandbox cannot run `xcodebuild`; execute the above commands on macOS or in CI.

## Debug Tools

### Provider Nutrient Name Sweeper

A debug-only tool (`Features/Debug/ProviderSweep/NutrientNameSweeper.swift`) that sweeps provider API responses to collect unique nutrient names for validation and test data generation.

**Usage:**
1. In DEBUG builds, navigate to Settings → DEBUG → "Run Provider Nutrient Sweep (FDC)"
2. Tap the button to run the sweep
3. Results are saved to `DebugOutput/Seed_NutrientNames_fdc.json` (gitignored)
4. The file contains:
   - Provider name (e.g., "FDC")
   - Search and detail response counts
   - Sorted array of unique nutrient names
   - Generation timestamp

**Generating Seed JSON for Provider Vocabularies:**
- Run the sweeper from the debug menu
- Check Xcode console for file path: `📁 Saved to: [path]`
- The generated JSON can be used as test fixtures or to validate nutrient name mappings
- File location: `Documents/DebugOutput/Seed_NutrientNames_fdc.json` (in simulator) or device Documents folder

**Testing:**
- `ProviderSweepTests` validates the sweeper result structure and encoding
- Tests verify unique nutrient names are properly deduplicated and sorted