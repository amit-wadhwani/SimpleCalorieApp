# ComponentMap.md
_Last updated: 2025-10-15_

This document maps **wireframes → SwiftUI components → data models → services** for the **SimpleCalorie** MVP.

> Design rule: **Small, reusable, testable** views with clear inputs (props) and no hidden side effects.

---

## 1) Screen → Route → Composition

| Screen (Wireframe) | Route ID | Composed Of |
|---|---|---|
| **Today** | `route.today` | `CalorieBarView`, `MacroBarView`, `ProjectionCardView`, `MealSectionView`(x4), `AddMealFAB`, `EncouragementBanner` |
| **Add Meal** | `route.addMeal` | `AddMealHeader`, `ModeTabs`, `FoodSearchView` \| `BarcodeScanView` \| `QuickAddView`, `PortionPicker`, `PrimaryButton` |
| **Weekly Summary** | `route.weekly` | `WeekPicker`, `SummaryStatCard`(x3), `WeeklyGraphView`, `HighlightsList`, `EncouragementBanner` |
| **Settings** | `route.settings` | `GoalEditor`, `IntegrationToggle(HealthKit)`, `ThemePicker`, `AboutBlock` |
| **Onboarding (3-step)** | `route.onboarding` | `WelcomeSlide`, `GoalWizard`, `ConfirmSlide` |

---

## 2) Reusable SwiftUI Components (Props & Responsibilities)

> **Naming:** `NounView` for UI, `…VM` for view models (only when local logic is non-trivial).

### Core Display

| Component | Props (examples) | Responsibility |
|---|---|---|
| `CalorieBarView` | `consumed: Int`, `goal: Int` | Horizontal progress with labels and % |
| `MacroBarView` | `protein: Int`, `carbs: Int`, `fat: Int`, `goal: MacroGoal?` | 3 segmented bars; optional target lines |
| `ProjectionCardView` | `todayCalories: Int`, `goalCalories: Int`, `currentWeight: Double`, `targetWeight: Double`, `ratePerWeek: Double?` | Computes/receives projection; animates text change |
| `MealSectionView` | `title: MealType`, `entries: [MealEntry]`, `onAdd: ()->Void`, `onDelete: (MealEntry)->Void` | Collapsible list for a meal (Breakfast, etc.) |
| `FoodRow` | `food: FoodItem`, `serving: Serving` | One row showing name, cals, macros |
| `SummaryStatCard` | `title: String`, `value: String`, `hint: String?` | Small card used on Weekly |
| `WeeklyGraphView` | `points: [DailyCaloriesPoint]`, `goal: Int` | Light line graph vs goal line |
| `EncouragementBanner` | `message: String` | Bottom nudge tone (“Awareness = Power”) |

### Input / Actions

| Component | Props | Responsibility |
|---|---|---|
| `AddMealFAB` | `onTap: ()->Void` | Floating + button on Today |
| `ModeTabs` | `selection: Binding<AddMode>` | Switch Search / Barcode / Quick Add |
| `FoodSearchView` | `query: Binding<String>`, `results: [FoodItem]`, `onSelect: (FoodItem)->Void` | Debounced search, shows verified items first |
| `BarcodeScanView` | `onFound: (FoodItem)->Void`, `onError: (ScanError)->Void` | Camera preview + barcode detection |
| `QuickAddView` | `calories: Binding<Int>`, `protein: Binding<Int?>`, `carbs: Binding<Int?>`, `fat: Binding<Int?>`, `onSave: ()->Void` | Manual entry with validation |
| `PortionPicker` | `servings: [Serving]`, `selection: Binding<Serving>` | Picker for size/qty |
| `WeekPicker` | `selected: Binding<WeekRef>` | Jump between weeks |
| `GoalEditor` | `dailyCalorieGoal: Binding<Int>` \| **(or)** `UserGoal` | Simple goal slider + text fields |
| `IntegrationToggle` | `isOn: Binding<Bool>` | HealthKit connect/disconnect |
| `ThemePicker` | `mode: Binding<AppThemeMode>` | Light/Dark/System |

---

## 3) Data Models (SwiftData / Codable)

```swift
enum MealType: String, Codable { case breakfast, lunch, dinner, snack }

struct Serving: Codable, Hashable {
  var sizeLabel: String        // "1 cup", "100 g", "1 bar"
  var grams: Double?           // optional for density math
  var multiplier: Double       // e.g., 1.0 = one serving
}

struct FoodItem: Codable, Identifiable, Hashable {
  var id: String               // db id or barcode if unique
  var name: String
  var brand: String?
  var barcode: String?
  var calories: Int
  var protein: Int             // grams
  var carbs: Int
  var fat: Int
  var defaultServing: Serving
  var altServings: [Serving]
  var source: FoodSource       // .verified, .userCreated, .scanned
}

struct MealEntry: Identifiable, Codable, Hashable {
  var id: UUID = .init()
  var food: FoodItem
  var serving: Serving
  var meal: MealType
  var timestamp: Date
}

struct DayLog: Identifiable, Codable {
  var id: String               // yyyy-MM-dd
  var date: Date
  var entries: [MealEntry]
  var totals: MacroTotals      // denormalized for speed
}

struct MacroTotals: Codable {
  var calories: Int
  var protein: Int
  var carbs: Int
  var fat: Int
}

struct UserGoal: Codable {
  var dailyCalories: Int
  var currentWeight: Double?
  var targetWeight: Double?
  var targetDate: Date?
}

struct DailyCaloriesPoint: Codable {
  var date: Date
  var calories: Int
}

enum FoodSource: String, Codable { case verified, userCreated, scanned }

Storage: SwiftData (or Core Data) for DayLog, MealEntry, UserGoal; on-disk cache for FoodItem search results.

## 4) App State & Architecture

Keep it simple: one AppStore (observable) + small feature-specific stores.

@Observable final class AppStore {
  var goal = UserGoal(dailyCalories: 1800)
  var today = DayLog(id: "2025-10-15", date: .now, entries: [], totals: .init(calories: 0, protein: 0, carbs: 0, fat: 0))
  var week: [DayLog] = []

  // Services (injected)
  let foods: FoodService
  let barcode: BarcodeService
  let health: HealthService
  let projection: ProjectionService
  let persistence: PersistenceService
}

	•	Navigation: simple TabView (Today / Weekly / Settings) + sheet for Add Meal.
	•	Dependency Injection: lightweight protocol-based services; pass into AppStore at init.
	•	Threading: all DB and network on background; UI updates on main.

## 5) Services (Protocols → Swappable Implementations)

Service
Protocol
Notes
FoodService
search(query) -> [FoodItem], lookup(barcode) -> FoodItem?
Start with OpenFoodFacts + local curation layer; later: USDA/Edamam adaptor
BarcodeService
start(), stop(), delegate with onCode(String)
AVFoundation wrapper
ProjectionService
project(todayCalories, goal, currentWeight?, target?) -> ProjectionResult
Transparent math; unit tests required
HealthService
syncWeight(), read/write calories?
HealthKit optional
PersistenceService
save(log), load(day), loadWeek()
SwiftData/CoreData
InsightsService (later)
“Top foods”, “avg deficit”, etc.
For Weekly Highlights

Projection math (transparent)
Assume 3,500 kcal ≈ 1 lb. Provide explicit explanation string used in UI.

## 6) Theming, Typography, Haptics
	•	Theme: AppThemeMode = light/dark/system.
	•	Color tokens: Color.primaryBG, Color.accent, Color.success, Color.warning.
	•	Haptics:
	•	.soft on successful add
	•	.warning on invalid form

## 7) Accessibility & Internationalization
	•	Dynamic Type supported on all text.
	•	VoiceOver labels on progress bars (“1,320 of 1,800 calories, 73%”).
	•	Date/number formatting via Locale.current.
	•	Strings in Localizable.xcstrings.

## 8) Error & Empty States

Context
Message
Action
Search no results
“No foods found.”
Button: “Quick Add Calories”
Barcode failure
“Couldn’t read barcode.”
Tip: “Try better lighting”
Network offline
“You’re offline — showing cached foods.”
Retry
First run (empty day)
“Let’s log your first meal.”
CTA: Add Meal


## 9) Analytics (privacy-first)

	•	Local event counters (no external SDK at MVP).
	•	Events: meal_added, quick_add_used, reuse_meal, projection_viewed, week_opened.
	•	Later: TelemetryDeck or homemade, with opt-in.

## 10) Testing Plan
	•	Unit tests: ProjectionServiceTests, FoodParsingTests, PortionMathTests.
	•	UI tests: Add Meal happy path (< 5s), Meal Reuse, Weekly swipe weeks.
	•	Snapshot tests: Today screen at empty, mid-day, complete.

## 11) Naming Conventions
	•	Views: SomethingView
	•	Models: nouns (FoodItem, DayLog)
	•	Services: XxxService + protocol XxxServicing (optional)
	•	IDs: yyyy-MM-dd for DayLog; UUID() for entries

## 12) Minimal Data Examples
{
  "food": {
    "id": "off:737628064502",
    "name": "Kind Bar - Almond & Sea Salt",
    "brand": "KIND",
    "barcode": "737628064502",
    "calories": 200,
    "protein": 6,
    "carbs": 16,
    "fat": 14,
    "defaultServing": { "sizeLabel": "1 bar", "grams": 40, "multiplier": 1.0 },
    "altServings": [{ "sizeLabel": "100 g", "grams": 100, "multiplier": 1.0 }],
    "source": "verified"
  }
}

## 13) MVP Cut List (stick to it)
	•	No micronutrients.
	•	No social/community.
	•	No complex streaks/gamification.
	•	Photos/AI logging → post-MVP.
	•	iCloud sync/export → post-MVP.

## 14) Open Questions
	•	Which food DB first: OpenFoodFacts (free) → add curated overrides?
	•	Do we store user foods locally only or allow cloud backup at v1?
	•	Projection: show range (confidence) or single number (simplicity)?


North Star: components stay tiny, explicit, and easy to test. If a view grows logic, extract a service or a tiny …VM.