# UserFlows.md  
_Last updated: 2025-10-15_  

---

## 🧭 Overview

This document defines the **core user flows** for the SimpleCalorie App MVP.  
Each flow is designed around the app’s core values — **simplicity, trust, and clarity** — and is optimized to minimize friction, maximize feedback, and guide the user naturally toward awareness and consistency.

> Design rule: Each primary action should take 3 taps or fewer.

---

## 🌱 Primary User Flows (MVP)

### 1. Onboarding Flow

**Goal:** Set up calorie goal, connect health data (optional), and get to first daily log.  
**Emotional intent:** Calm, friendly, quick. Feels like starting something doable.

#### Steps:
1. **Welcome screen**  
   - Message: “Let’s make eating simple again.”  
   - Options: “Get Started” → proceeds to setup.
2. **Goal setup**  
   - User enters weight, target weight, and timeframe (optional).
   - Auto-calculate suggested calorie goal (TDEE estimate).
3. **Optional integrations**  
   - Prompt: “Would you like to import weight or calories from Apple Health?”
4. **Theme & tone preference** *(optional MVP stretch)*  
   - Light/Dark/Auto theme toggle.
5. **Daily overview intro**  
   - Show “Today” screen preview with empty placeholders (to signal simplicity).
6. **Start tracking**  
   - CTA: “Add your first meal.” → jumps into Food Logging Flow.

✅ **End condition:** User lands on Today view with calorie goal displayed and ready to log first meal.  

🎨 **Visual Reference:** `/Design/Flows/OnboardingFlow.drawio`

---

### 2. Food Logging Flow

**Goal:** Let user add a food item with minimal steps.  
**Emotional intent:** Effortless, quick, accurate. Feels “instant.”

#### Steps:
1. Tap “+ Add Meal” on Today view.
2. Choose one:
   - **Search food** → start typing → autocomplete suggestions from verified DB.  
   - **Scan barcode** → instant lookup.  
   - **Quick add** → manual calories + macros entry.
3. Select serving size → confirm.
4. Food item added to meal section (Breakfast/Lunch/Dinner/Snack).
5. UI feedback: “Logged ✅” + subtle animation.
6. Day summary updates automatically (calories + macros).
7. Optional: one-tap “Repeat last meal.”

✅ **End condition:** Food successfully logged and totals updated.  
🎨 **Visual Reference:** `/Design/Flows/FoodLoggingFlow.drawio`

---

### 3. Daily Summary Flow

**Goal:** Provide a clear, motivating summary of intake and progress.  
**Emotional intent:** Calm, factual, motivating through clarity (not shame or guilt).

#### Steps:
1. User opens app → sees Today view.
2. Summary shows:
   - Total calories consumed vs goal.
   - Macronutrient bars (Protein, Carbs, Fat).  
   - Optional mini-graph for sugar, fiber, or net carbs.
3. Below, show **projection statement**:
   > “If you ate like this every day, you’d weigh X in Y weeks.”
4. Optionally scroll down for:
   - “Most calorie-dense foods today.”
   - “Your biggest source of protein.”
5. Subtle encouragement footer:  
   “Awareness = Power 💪 You’re doing great.”

✅ **End condition:** User feels informed and motivated to continue.  
🎨 **Visual Reference:** `/Design/Flows/DailySummaryFlow.drawio`

---

### 4. Meal Reuse Flow

**Goal:** Allow user to quickly re-add meals from the past.  
**Emotional intent:** Feels smart, efficient, and caring — “The app remembers me.”

#### Steps:
1. Tap “Add Meal.”
2. New option appears: “From Past Meals.”
3. Shows short list:
   - “Yesterday’s Breakfast”
   - “Last Monday’s Lunch”
   - “Top 5 repeated meals”
4. User taps → instantly logs entire meal.  
5. Feedback: “Meal copied ✅.”

✅ **End condition:** Meal re-logged instantly without search or scanning.  
🎨 **Visual Reference:** `/Design/Flows/MealReuseFlow.drawio`

---

### 5. Weekly Summary Flow

**Goal:** Give user simple long-term insight — no overwhelm.  
**Emotional intent:** Feels rewarding and clear. Encourages steady consistency.

#### Steps:
1. User taps “Weekly Summary” tab.
2. Summary shows:
   - Average daily calories.
   - Estimated average deficit/surplus.
   - Weight change projection.
   - Most frequent foods.
   - Encouraging insight: “You were consistent 5 of 7 days.”
3. CTA: “Set new target” → leads to Goal Adjustment Flow.

✅ **End condition:** User gains meaningful insight without confusion.  
🎨 **Visual Reference:** `/Design/Flows/WeeklySummaryFlow.drawio`

---

## 🔄 Supporting Flows (Later MVP or v1.1)

| Flow | Description | Priority |
|------|--------------|-----------|
| **Goal Adjustment Flow** | User updates weight or target → recalculates projection. | Medium |
| **AI Food Recognition Flow** | Take photo → detect and log food. | Low (future) |
| **Apple Watch Quick Log** | Add meals from watch face. | Medium (v1.1) |
| **Backup & Sync Flow** | iCloud sync or export logs to CSV. | Low |

---

## ⚙️ Design Principles for Flows

- **Frictionless:** No action should feel like data entry.  
- **Predictive:** Surfaces most likely choices (past meals, recent foods).  
- **Instant Feedback:** Visual confirmation for every action.  
- **Progressive Disclosure:** Keep advanced data (fiber, sugar, net carbs) hidden until user expands.  
- **Emotional Tone:** Encouraging, rational, non-patronizing.  
- **Speed Heuristic:** Any flow should complete in **under 15 seconds.**

---

## 🧩 Flow Integration Summary
Onboarding → Today Screen
↓
Add Meal → Food Logging Flow
↓
Daily Summary ↔ Weekly Summary
↓
Goal Adjustment (optional)
---

## ✅ Next Steps

- Create matching **Draw.io flowcharts** for:
  - OnboardingFlow.drawio  
  - FoodLoggingFlow.drawio  
  - DailySummaryFlow.drawio  
  - MealReuseFlow.drawio  
  - WeeklySummaryFlow.drawio
- Then move to **/Design/Wireframes.fig** for low-fidelity layout sketches.

---

© 2025 Amit Wadhwani. All rights reserved.