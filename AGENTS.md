# AGENTS GUIDE — SimpleCalorie

This document is for automated coding agents (like OpenAI Codex) that work on this repo.

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

(Currently minimal or none.)

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

### No-Ads Separator (to be simplified)

- The Today screen currently has *debug/options* for a “No-ADS separator” style:
  - Settings UI for choosing:
    - Invisible
    - Divider
    - Old capsule (1/2 line, left/center)
    - New capsule
  - Implementation lives mainly in:
    - `Features/Today/Cards/DecorSpacerCard.swift`
    - `Features/Today/Common/TodayLayout.swift`
    - Settings / debug toggles in Today-related views (e.g. `TodayRootView`).

### IMPORTANT: Current Task for Agents

When asked to “remove the No-ADS separator options and make the default old capsule, 1 line, centered”:

1. **Settings / toggles:**
   - Remove user-facing controls for the “Today Screen — No-ADS Separator” options
     from the Today-related settings / debug UI (e.g. the segmented control).
   - Do not leave dead UI or unused bindings behind.

2. **Layout logic:**
   - Simplify `TodayLayout` and `DecorSpacerCard` so that:
     - There is **no external configuration** of the separator.
     - The default and only behavior is:
       - Old capsule style
       - 1-line height
       - Centered horizontally
   - Keep the visual as it currently appears for:
     - “Old Capsule / 1 line / Centered” in the app.

3. **Code hygiene:**
   - Delete unused enums, `@AppStorage` keys and variants that existed purely for
     separator configuration, unless referenced elsewhere.
   - Keep behavior of other parts of the Today screen intact.

4. **Do not:**
   - Change non-related layout for Today cards, meals, FAB, or Add Food flow.
   - Alter the design tokens in `Design/*` or unrelated features.

## General Code Style

- Prefer small, focused SwiftUI views.
- Follow existing naming conventions.
- Avoid introducing external dependencies.
- Keep public APIs unchanged unless explicitly requested.

If in doubt about choices, prefer:
- Native iOS patterns (e.g., List swipe actions, sheets)
- Clear, readable code over cleverness.