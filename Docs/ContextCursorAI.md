Awesome—let’s hand this off to Cursor cleanly. Below is everything it needs (context, structure, file-by-file tasks, token mapping, and step order), plus the exact prompt line it expects.

⸻

Place this file at: Docs/ContextCursorAI.md

Project one-pager

App: SimpleCalorie (iOS, SwiftUI).
Goal of v0 flow: Build the Add Food screen using four reusable components: TopBar, SearchBar, ResultsHeader, FoodRow. Use mock data for now; wire for real data later.
Style source: Figma UI3 — tokens under the single root set global/* (typography, colors/text, component overrides). Keep spacing/paddings consistent with the spec (12–16 inside containers; 16 between blocks).

Tech baseline
	•	iOS 18, SwiftUI, SF Symbols.
	•	SwiftData enabled (not used in this task).
	•	Architecture: lightweight MVVM (View + ViewModel per feature/component where useful).
	•	Previews with fixtures.

Directory layout (inside the existing Xcode project folder SimpleCalorie/)

SimpleCalorie/
├─ App/
│  └─ AppRootView.swift
├─ Features/
│  └─ AddFood/
│     ├─ AddFoodView.swift
│     └─ AddFoodViewModel.swift
├─ Components/
│  ├─ TopBar/TopBarView.swift
│  ├─ SearchBar/SearchBarView.swift
│  ├─ ResultsHeader/ResultsHeaderView.swift
│  └─ FoodRow/
│     ├─ FoodRowView.swift
│     └─ FoodRowViewModel.swift
├─ Models/
│  ├─ Food.swift
│  └─ MacroInfo.swift
├─ Services/
│  └─ FoodSearchService/
│     ├─ FoodSearchService.swift
│     └─ MockFoodSearchService.swift
├─ Design/
│  ├─ Tokens/
│  │  └─ README.md
│  ├─ Colors.swift
│  ├─ Typography.swift
│  ├─ Spacing.swift
│  └─ Radius.swift
├─ Resources/
│  ├─ Assets.xcassets
│  └─ PreviewContent/
│     └─ Fixtures.json
├─ Tests/
│  ├─ SimpleCalorieTests/
│  └─ SimpleCalorieUITests/
└─ .gitignore

.gitignore (root of repo — if lines already exist, keep them)

# Xcode
DerivedData/
build/
*.xcuserdatad
*.xcuserdata
*.xccheckout
*.moved-aside

# SwiftPM
.swiftpm/
Packages/
Package.resolved

# Logs
*.log

# macOS
.DS_Store

Figma → code token mapping (use these names verbatim)

Tokens live under the single set global/*. Use these to style components. If a token is missing in code, create a constant in Design/* that references it by token path in comments so we can wire to a generator later.

Typography
	•	Top bar title: global/typography/title
	•	Food name (row): global/typography/titleSm
	•	Serving & labels (PROTEIN/CARBS/FAT): global/typography/bodySm
	•	Macro values (31g / 0g / 3.6g): global/component/FoodRow/macro/value/typography
	•	Results header (“8 RESULTS”): global/typography/labelCapsSm
	•	Calories number (165): global/component/FoodRow/kcal/value/typography
	•	Calories unit (“kcal”): global/typography/captionXs

Colors
	•	Title text: global/text/title
	•	Muted text (serving, units): global/text/muted
	•	Separator/strokes: global/border/subtle
	•	Card background: global/bg/card
	•	Macro value colors:
	•	Protein: global/color/macro/protein
	•	Carbs:   global/color/macro/carbs
	•	Fat:     global/color/macro/fat
	•	Primary icon/button (plus): global/brand/primary

Radius / Elevation / Spacing
	•	Card radius: global/radius/xl
	•	Search pill radius: global/radius/full
	•	Card shadow/elevation: global/elevation/card
	•	Spacing scale (use these names; they exist in global/space/*):
	•	global/space/12, global/space/16, global/space/24, global/space/30
	•	Inside-card vertical: 12
	•	Inside-card horizontal: 16
	•	Between blocks: 16
	•	Top bar → search: 24–30 (match spec you saw)

If any token is not yet exported to code, hardcode the value but add a // TODO(token: <path>) next to it.

Component contracts (props) & behaviors

TopBarView
	•	Props: title: String, onBack: () -> Void
	•	Layout: leading chevron chevron.backward + title set in global/typography/title, color global/text/title.
	•	Touch area ≥ 44×44.

SearchBarView
	•	Props: placeholder: String, text: Binding<String>
	•	Layout: capsule/pill with icon magnifyingglass; padding 12–16 inside, full radius; stroke global/border/subtle, fill global/bg/card.
	•	Text style global/typography/bodySm, color global/text/muted when empty.

ResultsHeaderView
	•	Props: count: Int
	•	Renders “N RESULTS” in global/typography/labelCapsSm, color global/text/muted, letter-spacing per token.

FoodRowView
	•	Props:

struct FoodRowProps: Identifiable {
    let id: UUID
    let name: String
    let serving: String   // e.g., "100g"
    let protein: String   // "31g"
    let carbs: String     // "0g"
    let fat: String       // "3.6g"
    let kcal: String      // "165"
}


	•	UI: white card with stroke global/border/subtle, radius global/radius/xl, internal H:16 / V:12.
	•	Left column: Name (titleSm), Serving (bodySm, muted), macros row: three blocks (label in muted, value colored by macro token).
	•	Right column: calories big number + “kcal” small, and a circular primary button with plus (44×44 min tap).
	•	Accessibility: elements grouped; plus button labeled “Add ”.

AddFoodView (feature composition)
	•	Props: none
	•	Contains: TopBarView, SearchBarView, ResultsHeaderView, List/ScrollView of FoodRowView.
	•	AddFoodViewModel:
	•	Input: query: String
	•	Output: [FoodRowProps]
	•	Uses FoodSearchService (mock implementation) to filter sample foods by name substring.

Services
	•	FoodSearchService: protocol w/ search(query: String) async -> [Food]
	•	MockFoodSearchService: returns static list (Chicken Breast, Brown Rice, etc.)

Models

struct MacroInfo { let protein: Double; let carbs: Double; let fat: Double }
struct Food: Identifiable {
    let id: UUID
    let name: String
    let servingGrams: Int
    let macros: MacroInfo
    var kcal: Int { /* simple calc, or fixed */ }
}

Design token shims (Swift)

Implement thin shims so all views use the same API:
	•	Colors.swift

enum AppColor {
    static let textTitle = Color("textTitle") // TODO(token: global/text/title)
    static let textMuted = Color("textMuted") // TODO(token: global/text/muted)
    static let borderSubtle = Color("borderSubtle") // TODO(token: global/border/subtle)
    static let bgCard = Color("bgCard") // TODO(token: global/bg/card)
    static let brandPrimary = Color("brandPrimary") // TODO(token: global/brand/primary)

    static let macroProtein = Color("macroProtein") // TODO(token: global/color/macro/protein)
    static let macroCarbs   = Color("macroCarbs")   // TODO(token: global/color/macro/carbs)
    static let macroFat     = Color("macroFat")     // TODO(token: global/color/macro/fat)
}


	•	Typography.swift (use system fonts until tokens export; tag with token paths)

import SwiftUI
enum AppFont {
    static func title(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .semibold) } // token: global/typography/title
    static func titleSm(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold) } // token: global/typography/titleSm
    static func bodySm(_ size: CGFloat = 13) -> Font { .system(size: size, weight: .regular) } // token: global/typography/bodySm
    static func labelCapsSm(_ size: CGFloat = 11) -> Font { .system(size: size, weight: .medium) } // token: global/typography/labelCapsSm
    static func captionXs(_ size: CGFloat = 10) -> Font { .system(size: size, weight: .regular) } // token: global/typography/captionXs
}


	•	Spacing.swift

enum AppSpace { static let s12: CGFloat = 12; static let s16: CGFloat = 16; static let s24: CGFloat = 24; static let s30: CGFloat = 30 } 
// tokens: global/space/12, /16, /24, /30


	•	Radius.swift

enum AppRadius { static let xl: CGFloat = 16; static let full: CGFloat = 999 } 
// tokens: global/radius/xl, global/radius/full



Step order (what to do first to last)
	1.	Create folders & files (tree above) + .gitignore.
	2.	Implement Design shims (Colors, Typography, Spacing, Radius) with token TODOs.
	3.	Build Components (TopBar, SearchBar, ResultsHeader, FoodRow) with previews using hardcoded props.
	4.	Add Models + Mock service + ViewModels.
	5.	Compose AddFoodView using the components and mock VM.
	6.	AppRootView shows AddFoodView.
	7.	Add fixtures to Resources/PreviewContent/Fixtures.json and use them in previews.
	8.	Accessibility labels & minimum hit targets (≥44pt).
	9.	Run build; ensure previews render.