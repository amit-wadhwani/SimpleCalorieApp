import SwiftUI

struct SmartSuggestionsRow: View {
    enum MealKind {
        case breakfast
        case lunch
        case dinner
        case snacks
    }
    
    let mealKind: MealKind
    let layoutMode: TodaySuggestionsLayoutMode
    let hasYesterday: Bool
    let hasLastWeekOrNight: Bool
    let onYesterdayTapped: () -> Void
    let onLastWeekOrLastNightTapped: () -> Void
    let onCopyFromDateTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SMART SUGGESTIONS")
                .font(.caption2.smallCaps())
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .accessibilityIdentifier("smartSuggestionsLabel")

            chipLayout
        }
    }

    @ViewBuilder
    private var chipLayout: some View {
        switch layoutMode {
        case .horizontal:
            HStack(spacing: 8) {
                chips
            }
        case .vertical:
            VStack(alignment: .leading, spacing: 8) {
                chips
            }
        }
    }

    @ViewBuilder
    private var chips: some View {
        if hasYesterday {
            suggestionChip(
                icon: AnyView(
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(emerald)
                ),
                label: yesterdayLabel,
                action: onYesterdayTapped
            )
        }
        
        if hasLastWeekOrNight {
            suggestionChip(
                icon: AnyView(
                    Image(systemName: lastWeekOrNightIconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(lastWeekOrNightColor)
                ),
                label: lastWeekOrNightLabel,
                action: onLastWeekOrLastNightTapped
            )
        }
        
        // Copy from Date is always visible
        suggestionChip(
            icon: AnyView(
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(amber)
            ),
            label: "Copy from Date…",
            action: onCopyFromDateTapped
        )
        .accessibilityIdentifier("copyFromDateChip")
    }
}

private extension SmartSuggestionsRow {
    // Colors from swipe design (softened a bit)
    var emerald: Color {
        Color(red: 0.20, green: 0.83, blue: 0.60) // #34D399-ish
    }
    
    var indigo: Color {
        Color(red: 0.51, green: 0.55, blue: 0.97) // #818CF8-ish
    }
    
    var sky: Color {
        Color(red: 0.22, green: 0.74, blue: 0.97) // #38BDF8-ish
    }
    
    var amber: Color {
        Color(red: 1.00, green: 0.75, blue: 0.14) // #FBBF24-ish
    }
    
    var yesterdayLabel: String {
        switch mealKind {
        case .breakfast: return "Yesterday’s Breakfast"
        case .lunch:     return "Yesterday’s Lunch"
        case .dinner:    return "Yesterday’s Dinner"
        case .snacks:    return "Yesterday’s Snacks"
        }
    }
    
    var lastWeekOrNightLabel: String {
        switch mealKind {
        case .breakfast: return "Last Week’s Breakfast"
        case .lunch:     return "Last Night’s Dinner"
        case .dinner:    return "Last Week’s Dinner"
        case .snacks:    return "Last Week’s Snacks"
        }
    }
    
    var lastWeekOrNightIconName: String {
        switch mealKind {
        case .breakfast, .dinner, .snacks:
            return "calendar"
        case .lunch:
            return "moon.stars"
        }
    }
    
    var lastWeekOrNightColor: Color {
        switch mealKind {
        case .breakfast, .dinner, .snacks:
            return indigo
        case .lunch:
            return sky
        }
    }
    
    func suggestionChip(
        icon: AnyView,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                icon
                
                Text(label)
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .label))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minHeight: 32)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1) // #E5E5EA
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct SmartSuggestionsRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmartSuggestionsRow(
                mealKind: .breakfast,
                layoutMode: .horizontal,
                hasYesterday: true,
                hasLastWeekOrNight: true,
                onYesterdayTapped: {},
                onLastWeekOrLastNightTapped: {},
                onCopyFromDateTapped: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            SmartSuggestionsRow(
                mealKind: .lunch,
                layoutMode: .horizontal,
                hasYesterday: true,
                hasLastWeekOrNight: true,
                onYesterdayTapped: {},
                onLastWeekOrLastNightTapped: {},
                onCopyFromDateTapped: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            SmartSuggestionsRow(
                mealKind: .dinner,
                layoutMode: .vertical,
                hasYesterday: true,
                hasLastWeekOrNight: true,
                onYesterdayTapped: {},
                onLastWeekOrLastNightTapped: {},
                onCopyFromDateTapped: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            SmartSuggestionsRow(
                mealKind: .snacks,
                layoutMode: .horizontal,
                hasYesterday: false,
                hasLastWeekOrNight: true,
                onYesterdayTapped: {},
                onLastWeekOrLastNightTapped: {},
                onCopyFromDateTapped: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
#endif
