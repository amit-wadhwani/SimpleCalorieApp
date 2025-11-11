# WireframeLayoutPlan.md  
_Last updated: 2025-10-15_  

---

## 🧭 Overview

This document defines the **screen-by-screen wireframe plan** for the **SimpleCalorie App (MVP)**.  
Each screen specifies layout zones, UI components, key interactions, and **emotional tone** — ensuring both usability and the app’s signature calm, trustworthy vibe.

> Design philosophy: “Beautiful clarity.”  
> Every screen should answer: *“What’s the one thing the user should feel or do right now?”*

---

## 🏠 1. Today Screen (Home)

**Purpose:** The main hub. Quick awareness of calorie progress and motivation through projection.  

**Primary user actions:**  
- View total intake vs goal.  
- Log food via + button.  
- See macros and projection at a glance.  

### 🧱 Layout Structure

| Section | Elements | Notes |
|----------|-----------|-------|
| **Top Bar** | App name (“SimpleCalorie”), settings icon ⚙️ | Calm typography, no clutter. |
| **Progress Ring / Calorie Bar** | Circular progress (optional) or horizontal bar: “1,320 / 1,800 kcal” | Keep readable, minimal color. |
| **Macro Snapshot** | 3 bars (Protein / Carbs / Fats) | Optional micro-toggle: tap to expand for sugar, sat fat. |
| **Projection Card** | Text block: “If you ate like this every day, you’d weigh 155 lbs in 6 weeks.” | Centered. Subtle animation when data updates. |
| **Meal Sections** | Collapsible: Breakfast, Lunch, Dinner, Snacks | Each shows foods + calories. “Add meal” button at bottom of each. |
| **Footer** | Tabs: Today / Weekly / Add | Use large tappable icons. |

### 🎨 Emotional Tone
- Calm focus: whitespace, muted palette.  
- Encouraging but factual.  
- Motion = feedback, not flair.  

🎨 **Visual Reference:** `/Design/Wireframes.fig → Frame: TodayScreen`

---

## ➕ 2. Add Meal Screen

**Purpose:** Make logging as frictionless as texting.  

**Primary user actions:**  
- Search, scan, or quick add.  
- Confirm serving and save.  

### 🧱 Layout Structure

| Section | Elements | Notes |
|----------|-----------|-------|
| **Top Bar** | “Add Meal” title + cancel (X) | Keep centered title for balance. |
| **Tabs** | Search / Barcode / Quick Add | 3-segment control toggle. |
| **Search Mode** | Text field → autocomplete list → tap → confirm portion. | Smart sorting (recent, popular). |
| **Barcode Mode** | Live camera + square guide + flash toggle. | Immediate scan feedback. |
| **Quick Add** | Fields: calories, protein, carbs, fat. | Optional description. |
| **Confirm Section** | Large “Add” button (green/blue tone). | When tapped → confetti pulse feedback. |

### 🎨 Emotional Tone
- Feels fast and reliable.  
- Micro animation confirms success instantly.  
- Motion: “snap” feel when item added.  

🎨 **Visual Reference:** `/Design/Wireframes.fig → Frame: AddMealScreen`

---

## 📈 3. Weekly Summary Screen

**Purpose:** Show patterns, not punishment.  

**Primary user actions:**  
- View average calories + macro breakdown.  
- Identify trends.  
- Adjust goals.  

### 🧱 Layout Structure

| Section | Elements | Notes |
|----------|-----------|-------|
| **Header** | Title: “This Week” + week selector. | Tap to view past weeks. |
| **Summary Stats** | Cards: Avg Cal/day, Est. deficit/surplus, Weight projection. | Use consistent visual rhythm. |
| **Graph Section** | Simple line graph (Calories vs Goal). | Keep minimal, soft colors. |
| **Highlights Section** | “Most logged foods” / “Most protein-rich meal.” | Text-based, not photo grid. |
| **Encouragement Card** | “You were consistent 5 of 7 days — great work.” | Always positive framing. |

### 🎨 Emotional Tone
- Factual → positive → calm.  
- Slightly warmer palette than Today screen.  
- Subtle animation when swiping between weeks.  

🎨 **Visual Reference:** `/Design/Wireframes.fig → Frame: WeeklySummaryScreen`

---

## ⚙️ 4. Settings Screen

**Purpose:** Manage preferences without intimidation.  

**Primary user actions:**  
- Adjust calorie goal.  
- Toggle themes.  
- Manage integrations (Apple Health).  

### 🧱 Layout Structure

| Section | Elements | Notes |
|----------|-----------|-------|
| **Header** | “Settings” | Use calm tone, clean layout. |
| **Goal Settings** | Text + slider for daily calorie goal. | Optional: link to target weight calculator. |
| **Integrations** | Apple Health toggle + permission status. | Use icons for clarity. |
| **Theme & Appearance** | Light / Dark / Auto toggle. | Preview small swatches. |
| **About Section** | “Made with ❤️ for simplicity.” | Optional app version & privacy link. |

### 🎨 Emotional Tone
- Feels personal and respectful.  
- Soft background, clear typography.  
- No overwhelm; focus on trust.

🎨 **Visual Reference:** `/Design/Wireframes.fig → Frame: SettingsScreen`

---

## 🔁 5. Onboarding Screens (3-part intro)

**Purpose:** Welcome and orient.  

### 🧱 Layout Structure

| Screen | Elements | Notes |
|---------|-----------|-------|
| **1. Welcome** | Logo, tagline: “Simple. Clear. Motivating.” | CTA: “Get Started.” |
| **2. Goal Setup** | Weight inputs, target goal, timeframe. | Auto-calculates daily target. |
| **3. Confirmation** | “You’re all set.” → CTA: “Start Logging.” | Smooth fade to Today screen. |

🎨 **Visual Reference:** `/Design/Wireframes.fig → Frame: OnboardingScreens`

---

## 💡 Reusable Components (for SwiftUI mapping)

| Component | Purpose |
|------------|----------|
| **CalorieBarView** | Horizontal progress bar with goal % label. |
| **MacroBarView** | Small segmented bars for P/C/F with tooltips. |
| **ProjectionCardView** | Dynamic card with projected weight + animation. |
| **MealCardView** | Displays food entries for each meal type. |
| **WeeklyGraphView** | Lightweight calorie trend line. |
| **EncouragementBanner** | Bottom footer with dynamic messages. |

---

## 🔤 Typography & Color (for Wireframes)

| Element | Font | Style |
|----------|------|-------|
| Titles | SF Pro Rounded | Bold, 22pt |
| Body | SF Pro Text | Regular, 16pt |
| Accent | SF Pro Display | Medium, 18pt |

| Purpose | Color | Notes |
|----------|--------|-------|
| Background | #F9FAFB | Soft neutral white |
| Primary Text | #1C1C1E | Nearly black |
| Accent | #0A84FF | Calm blue (Apple default) |
| Success | #34C759 | Used in confirmations |
| Warning | #FF9500 | Optional, gentle only |
| Shadow | rgba(0,0,0,0.05) | Minimal depth only |

---

## 🎯 Next Steps

1. Create frames for each screen in **Figma → `/Design/Wireframes.fig`** using the above layout notes.  
2. Once low-fidelity wireframes are done, export them as PNGs → link them back into this document.  
3. Next phase: create **UI Component Map** (`/Docs/ComponentMap.md`) to define reusable SwiftUI views (CalorieBar, ProjectionCard, etc.).  
4. Start connecting flows visually using **Draw.io** diagrams → link to each wireframe frame.

---

© 2025 Amit Wadhwani. All rights reserved.