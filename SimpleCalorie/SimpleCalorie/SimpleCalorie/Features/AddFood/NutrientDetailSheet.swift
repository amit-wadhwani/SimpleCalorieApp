import SwiftUI

struct NutrientDetailSheet: View {
    let type: MicronutrientType
    /// Amount in this food's base serving, using the nutrient's base units
    /// (g for fiber/sugar, mg for sodium/cholesterol/potassium).
    let amount: Double?

    @Environment(\.dismiss) private var dismiss

    // DV explanation line, always present when we have an amount and reference.
    private var dailyValueLine: String? {
        guard let amount = amount,
              let percent = type.dailyPercentage(for: amount) else {
            return nil
        }

        let signal = type.signal(for: amount)
        
        let label: String
        switch type {
        case .fiber:
            label = "a typical daily fiber target"
        case .sugar:
            label = "a typical daily sugar limit"
        case .sodium:
            label = "a typical daily sodium limit"
        case .cholesterol:
            label = "a typical daily cholesterol limit"
        case .potassium:
            label = "a typical daily potassium target"
        }
        
        let percentText: String
        if percent <= 0 {
            // Less than 1% but still worth mentioning
            percentText = "less than 1%"
        } else {
            percentText = "\(percent)%"
        }
        
        let status: String
        switch signal {
        case .good:
            status = "— Good 👍"
        case .moderate:
            status = "— Moderate •"
        case .lowHigh:
            status = "— Low ⚠️"
        }
        
        return "This serving is about \(percentText) of \(label) \(status)"
    }
    
    private var dvColor: Color {
        guard let amount = amount else {
            return AppColor.textMuted
        }
        let signal = type.signal(for: amount)
        switch signal {
        case .good:
            return Color(red: 0.26, green: 0.76, blue: 0.42)  // Good
        case .moderate:
            return Color(red: 0.40, green: 0.55, blue: 0.86)  // Moderate
        case .lowHigh:
            return Color(red: 0.96, green: 0.68, blue: 0.23)  // Low/High
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                // Left dot, horizontally aligned with Done
                Circle()
                    .fill(type.accentColor.opacity(0.7))
                    .frame(width: 6, height: 6)
                    .padding(.leading, 24)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.accentColor)
                .padding(.trailing, 24)
            }
            .padding(.top, 24)

            // Title
            Text(type.displayTitle)
                .font(.system(size: 32, weight: .bold))
                .tracking(-0.5)
                .foregroundStyle(AppColor.textTitle)
                .padding(.top, 12)
                .padding(.horizontal, 24)

            // Short underline under the title (32pt width, 2pt height, 8pt below title)
            Rectangle()
                .fill(type.accentColor)
                .frame(width: 32, height: 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.horizontal, 24)

            // Single divider under header
            Divider()
                .padding(.top, 16)
                .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // DV explanation line (always present when available)
                    if let dvLine = dailyValueLine {
                        Text(dvLine)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(dvColor.opacity(0.9))
                            .padding(.bottom, 2)
                    }

                    // Body paragraphs from type.detailBodyText (filter empty)
                    let paragraphs = type.detailBodyText.components(separatedBy: "\n\n")
                        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    
                    ForEach(paragraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(AppColor.textMuted)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Shared disclaimer
                    Text("These notes are general information, not medical advice. Your own ideal ranges can vary based on your health and goals.")
                        .font(.footnote)
                        .foregroundStyle(AppColor.textMuted)
                        .italic()
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
        }
    }
}
