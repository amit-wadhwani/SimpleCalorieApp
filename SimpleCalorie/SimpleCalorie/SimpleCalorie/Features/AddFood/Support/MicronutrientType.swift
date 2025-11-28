import SwiftUI

/// The micronutrients we currently surface in the Add Food detail sheet.
/// Base units:
/// - fiber, sugar: grams
/// - sodium, cholesterol, potassium: milligrams
enum MicronutrientType: CaseIterable, Identifiable {
    case fiber
    case sugar
    case sodium
    case cholesterol
    case potassium

    var id: String {
        displayTitle
    }

    var displayTitle: String {
        switch self {
        case .fiber:       return "Fiber"
        case .sugar:       return "Sugar"
        case .sodium:      return "Sodium"
        case .cholesterol: return "Cholesterol"
        case .potassium:   return "Potassium"
        }
    }

    /// Whether this nutrient is typically expressed in milligrams.
    var isMilligramBased: Bool {
        switch self {
        case .fiber, .sugar:
            return false
        case .sodium, .cholesterol, .potassium:
            return true
        }
    }

    /// Short inline explanation used in the full nutrition list.
    /// Keep this to a few words; it's meant to answer "why does this matter?"
    /// - Parameter alwaysShow: If true, returns hint even when value is 0
    func inlineHint(for value: Double, alwaysShow: Bool = false) -> String? {
        // If value is 0 and alwaysShow is false, skip the hint
        if !alwaysShow && value == 0 {
            return nil
        }

        switch self {
        case .fiber:
            return "digestion"
        case .sugar:
            return "steady energy ⚡"
        case .sodium:
            return "blood pressure"
        case .cholesterol:
            return "heart health ❤️"
        case .potassium:
            return "muscle support 💪"
        }
    }

    /// Simple reference daily amounts (approximate; for educational DV-style messages).
    /// Values are in grams for fiber/sugar and milligrams for sodium/cholesterol/potassium.
    var dailyReferenceAmount: Double? {
        switch self {
        case .fiber:
            return 28.0    // g
        case .sugar:
            return 50.0    // g (placeholder for total sugars)
        case .sodium:
            return 2300.0  // mg
        case .cholesterol:
            return 300.0   // mg
        case .potassium:
            return 3400.0  // mg
        }
    }

    /// Percentage of a simple daily guideline for the given amount (in this nutrient's base units).
    func dailyPercentage(for amount: Double) -> Int? {
        guard let reference = dailyReferenceAmount,
              reference > 0,
              amount > 0 else {
            return nil
        }
        let percent = (amount / reference) * 100.0
        return Int(percent.rounded())
    }

    /// Accent color for the nutrient detail sheet underline.
    var accentColor: Color {
        switch self {
        case .fiber:
            return Color(red: 0.42, green: 0.56, blue: 0.55)    // soft neutral teal, not a signal color
        case .sugar:
            return Color(red: 0.82, green: 0.48, blue: 0.60)   // soft neutral pink
        case .sodium:
            return Color(red: 0.50, green: 0.62, blue: 0.90)   // soft neutral blue
        case .cholesterol:
            return Color(red: 0.90, green: 0.52, blue: 0.48)    // soft neutral red
        case .potassium:
            return Color(red: 0.60, green: 0.52, blue: 0.88)   // soft neutral purple
        }
    }

    /// Status signal for the inline row (good / moderate / low-high).
    func signal(for value: Double) -> MicronutrientSignal {
        guard let percent = dailyPercentage(for: value) else {
            // No DV context; treat as moderate/neutral.
            return .moderate
        }

        switch self {
        case .fiber, .potassium:
            // More is generally good up to a point.
            if percent < 25 { return .lowHigh }     // low
            if percent <= 100 { return .good }
            return .lowHigh                          // above reference → highlight
        case .sugar, .sodium, .cholesterol:
            // Lower is generally better.
            if percent <= 25 { return .good }
            if percent <= 100 { return .moderate }
            return .lowHigh                          // high vs typical guideline
        }
    }

    /// Long-form explanatory copy for the nutrient detail sheet.
    var detailBodyText: String {
        switch self {
        case .fiber:
            return """
Fiber supports digestion and can help with weight management. It's found in fruits, vegetables, whole grains, and legumes.



Most adults benefit from roughly 25–35 g of fiber per day, depending on appetite, activity, and individual needs.
"""
        case .sugar:
            return """
Natural sugars in whole foods come with fiber and nutrients. Added sugars, however, can lead to energy spikes and crashes.



Many health guidelines suggest limiting added sugars to about 25–36 g per day for most adults.
"""
        case .sodium:
            return """
Sodium helps regulate fluid balance and nerve signals. Too much, though, can raise blood pressure in some people.



General guidelines suggest keeping sodium intake under about 2,300 mg per day, with an ideal limit of around 1,500 mg for many adults.
"""
        case .cholesterol:
            return """
Cholesterol is used for hormones and cell membranes. Dietary cholesterol affects people differently, but consistently high intakes—combined with other lifestyle factors—may raise heart disease risk.



Many health organizations suggest paying attention to high-cholesterol foods as part of an overall balanced diet.
"""
        case .potassium:
            return """
Potassium supports muscle contractions, heart rhythm, hydration, and nerve function. Many people consume less potassium than recommended.



Daily targets vary, but many guidelines suggest around 2,500–3,000 mg per day for adults.
"""
        }
    }
}

/// Status used for micronutrient icons and legend.
enum MicronutrientSignal {
    case good
    case moderate
    case lowHigh
    
    var label: String {
        switch self {
        case .good: return "Good"
        case .moderate: return "Moderate"
        case .lowHigh: return "Low/High"
        }
    }
    
    var statusLabel: String {
        switch self {
        case .good: return "Good"
        case .moderate: return "Moderate"
        case .lowHigh: return "Low"
        }
    }
    
    var statusEmoji: String {
        switch self {
        case .good: return "👍"
        case .moderate: return ""
        case .lowHigh: return "⚠️"
        }
    }
    
    var defaultColor: Color {
        switch self {
        case .good:
            return Color(red: 0.19, green: 0.67, blue: 0.37)   // green
        case .moderate:
            return Color(red: 0.27, green: 0.45, blue: 0.70)   // slate-blue
        case .lowHigh:
            return Color(red: 0.98, green: 0.70, blue: 0.27)   // amber
        }
    }

    /// Icon view with provided color, used both in inline rows and in the legend.
    /// For neutral monochrome mode, use gray colors instead of signal colors.
    func icon(color: Color) -> some View {
        switch self {
        case .good:
            return AnyView(
                Image(systemName: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(color)
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] }
            )
        case .moderate:
            return AnyView(
                Text("—")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .foregroundStyle(color)
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] }
            )
        case .lowHigh:
            return AnyView(
                Image(systemName: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(color)
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] }
            )
        }
    }
}


