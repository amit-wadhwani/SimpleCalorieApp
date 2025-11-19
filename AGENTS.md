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