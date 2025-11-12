Master Project Context for ChatGPT + Cursor AI

Last updated: 2025-11-14

⸻

1. Project Purpose

SimpleCalorie is a clean, modern, Figma-faithful calorie tracking app.
The goal is pixel-accurate UI, stable logic, clean SwiftUI architecture, and predictable Cursor automation.

This document provides every design rule, preference, bug history, architectural expectation, and Cursor instruction pattern required to continue development with zero context lost across sessions.

⸻

2. High-Level Goals
	•	Replicate Figma visuals exactly: spacing, colors, typography, shadows, card structure, FAB, and component hierarchy.
	•	Smooth, logic-correct food tracking (calories + macros).
	•	Predictable and regression-free SwiftUI view updates.
	•	Cursor AI should perform surgical edits, not broad rewrites.
	•	Avoid duplication bugs, state mis-binding, or view misalignment.

⸻

3. Design Principles

✔️ Clean, white, breathable UI (Figma style)

✔️ Neutral color scheme with a blue accent (brandPrimary)

✔️ Consistent card radius, spacing, typography

✔️ Minimal visual noise

✔️ “Like the original SimpleCalorie app, but polished and premium”

✔️ Layout should never feel crowded

✔️ Vertical spacing is generous, matching Figma spec

⸻

4. Your Personal UI Preferences (Critical)

General
	•	The UI must always match the Figma screenshots exactly — no deviations.
	•	Prefer subtle shadows and rounded corners.
	•	Never collapse spacing (“bunched views” are unacceptable).

Color Preferences
	•	FAB must always be the blue accent (brandPrimary).
	•	Add Food “+ Add Food” row text must be blue, centered.
	•	Date picker selected date should use blue highlight, not navy or gray.
	•	Macro bars: Protein (green), Carbs (blue), Fat (orange) — as they are now.

Add Food Screen
	•	Rows should be long, spanning nearly the full width like the earlier screenshot.
	•	Macro numbers should follow the original layout (P/C/F in a tidy horizontal row).
	•	Avoid the compressed P/C/F vertical stack that Cursor accidentally introduced.

Today Screen
	•	No duplication of:
	•	CalorieSummaryCard
	•	MacrosSectionView
	•	Card order:
	1.	TodayHeaderView
	2.	CalorieSummaryCard
	3.	MacrosSectionView
	4.	Motivation/Ad cards
	5.	Each meal card (Breakfast, Lunch, Dinner, Snacks)
	6.	Footer spacing

Meal Cards
	•	Remove chevrons unless they actually navigate somewhere.
	•	Enable swipe-to-delete on meal items.
	•	Placeholder logic:
	•	If meal is empty and a previous day’s meal exists → show “Swipe right to add items…”
	•	Else show nothing.

FAB
	•	Blue
	•	Circular
	•	56×56 pt
	•	White plus icon
	•	Positioned in bottom-right safe area
	•	Soft shadow matching Figma

⸻

5. Known Bugs From Previous Commits (Must Avoid)

UI Bugs
	•	❌ Duplicate calorie + macro blocks appearing twice
	•	❌ Blue color not applied to FAB
	•	❌ Add Food macros formatted incorrectly
	•	❌ Add Food rows suddenly shorter and tighter
	•	❌ Add Food rows using weird P/C/F condensed styling
	•	❌ DatePicker blue accent lost
	•	❌ SearchBarView background not matching Figma
	•	❌ “Add Food” row text black, not blue
	•	❌ “Add Food” row not centered
	•	❌ Meal section logic causing double rendering
	•	❌ Wrong card padding compared to Figma
	•	❌ ZStack clipping FAB or cards

Functional Bugs
	•	❌ Macros not updating after adding food
	•	❌ Calories sometimes update but macros don’t
	•	❌ Meal rows not refreshing after mutation
	•	❌ Swipe-to-delete missing
	•	❌ Navigation chevrons misleading and non-functional
	•	❌ Crash after last pack due to view identity collisions

⸻

6. Figma Specs Summary

(These are extremely important for Cursor alignment.)

Cards
	•	Corner radius: 20
	•	Background: solid white
	•	Shadow: subtle, soft (~3–5% opacity)
	•	Horizontal padding: 16–20 pt
	•	Vertical spacing between cards: 20–28 pt

Typography (Typography.swift)
	•	Title bold
	•	Section title semibold
	•	Body regular
	•	Muted text uses textMuted Color asset

Colors (Colors.swift)
	•	brandPrimary → the official blue accent
	•	textTitle → near-black
	•	textMuted → gray (Figma muted style)
	•	bgCard → card white
	•	pageBg → extremely light gray

Add Food Row
	•	Full-width card
	•	Protein/Carbs/Fat inline with subtle colors
	•	Right-aligned kcal
	•	Big “+” button (blue outline or blue fill matching Figma)

Date Picker
	•	Clean, white
	•	Blue selected circle
	•	Gray weekday text
	•	Minimal navigation arrows

Tab Bar
	•	Icon size ~22 pt
	•	Labels muted
	•	Selected item uses brandPrimary

⸻

7. Core Architectural Expectations
	•	TodayRootView owns all day-level state.
	•	TodayViewModel computes totals and macros.
	•	ViewModel must always update meals + macros atomically.
	•	Views must not create duplicate sections.
	•	No broad rewrites — changes must stay localized to specific files.

⸻

8. Critical Files Cursor Will Touch

These are the files we will allow Cursor to modify:

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/Cards/
    AdCardView.swift
    MotivationCardView.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/Common/
    FloatingAddButton.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/Calories/
    CalorieSummaryCard.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/FoodRow/
    FoodRowView.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/Header/
    TodayHeaderView.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/Macros/
    MacrosSectionView.swift
    MacroRow.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/Meals/
    MealSectionView.swift
    MealSectionCard.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/DatePicker/
    DatePickerSheet.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/TabBar/
    TodayTabBarView.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Components/SearchBar/
    SearchBarView.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Features/Today/
    TodayRootView.swift
    TodayScreen.swift
    TodayViewModel.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Features/AddFood/
    AddFoodView.swift
    AddFoodViewModel.swift

SimpleCalorie/SimpleCalorie/SimpleCalorie/Design/
    Colors.swift
    Typography.swift
    Spacing.swift
    Radius.swift


⸻

9. Cursor Instruction Rules (VERY IMPORTANT)

These rules drastically reduce hallucinations and mistakes:

⸻

✔️ Rule 1 — Always reference files explicitly

Example:

Modify SimpleCalorie/.../TodayScreen.swift
Inside the VStack at line ~45, replace the HStack with...


⸻

✔️ Rule 2 — Never rename views unless instructed

Renaming breaks SwiftUI diffing and causes crashes.

⸻

✔️ Rule 3 — Use diff-style code blocks

Always provide code like:

// BEFORE
.padding(.horizontal, 8)

// AFTER
.padding(.horizontal, Spacing.lg)


⸻

✔️ Rule 4 — Never touch unrelated files

Cursor must only update the files listed in section 8.

⸻

✔️ Rule 5 — Always use Color assets & Typography

Never use .blue, .gray, .black.

Correct:

.foregroundColor(Color("brandPrimary"))
.font(Typography.body)

Incorrect:

.foregroundColor(.blue)
.font(.body)


⸻

✔️ Rule 6 — Maintain view identity

If a view is displaying twice, it means identity changed.
Cursor must not rewrite the entire view.

⸻

✔️ Rule 7 — Apply Figma spacing tokens

Use:

Spacing.xs = 4  
Spacing.sm = 8  
Spacing.md = 16  
Spacing.lg = 20  
Spacing.xl = 24  

No hard-coded values unless absolutely necessary.

⸻

✔️ Rule 8 — Respect ZStack safe areas

FAB must always remain unclipped.

⸻

10. Required Fixes (Agreed Priorities)

Add Food Screen
	•	Revert macro formatting to old version.
	•	Keep extended full-width rows.
	•	Make the “+” button blue (brandPrimary).
	•	Ensure spacing matches Figma.

Today Screen
	•	Fix duplicated summary + macros.
	•	Meal macros must update after adding food.
	•	Remove chevrons everywhere unless a navigation destination exists.
	•		•	Add Food row → blue, centered, correct padding.
	•	Correct spacing between meals.
	•	Restore the polished card look.

Date Picker
	•	Restore blue selection.
	•	Restore older styling (you preferred the earlier version).

Meal Logic
	•	Add swipe-to-delete.
	•	Remove chevrons.
	•	Placeholder logic as described above.

FAB
	•	Make it blue.
	•	Increase shadow like Figma.

Ad & Motivation Cards
	•	Good enough — do not regress.

⸻

11. Strategy For Next Session
	1.	Start new chat.
	2.	Upload repo ZIP.
	3.	Upload SimpleCalorie_ContextCapsule.md (this file).
	4.	Say:
“Load both files and confirm when ready.”
	5.	Then I will:
	•	Read the entire repo structure
	•	Open all Swift files directly
	•	Inspect styling tokens
	•	Create one clean Cursor instruction pack
	•	Fix everything without reintroducing regressions

⸻

12. Final Notes

This MD file is designed to be:
	•	Readable
	•	Durable
	•	Complete
	•	Self-contained
	•	Importable across all future sessions

It captures the entire cognitive state of the project up to now.

You can update it over time if new rules or preferences emerge.
