import SwiftUI

struct MacrosSectionView: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @Environment(\.colorScheme) private var colorScheme
    

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MACROS")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(AppColor.textMuted)

                Spacer()

                Button {
                    Haptics.selection()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        viewModel.isMacrosCollapsed.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.isMacrosCollapsed ? "Show" : "Hide")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColor.textMuted)

                        Image(systemName: viewModel.isMacrosCollapsed ? "chevron.down" : "chevron.up")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColor.textMuted)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 999)
                            .fill(AppColor.bgCard.opacity(0.9))
                    )
                }
            }
            .padding(.horizontal, AppSpace.s16)

            if !viewModel.isMacrosCollapsed {
                VStack(alignment: .leading, spacing: 12) {
                    MacroRow(
                        label: "Protein",
                        value: Int(viewModel.protein),
                        goal: Int(viewModel.proteinGoal),
                        color: AppColor.macroProtein
                    )
                    .animation(.easeOut(duration: 0.4), value: viewModel.protein)

                    MacroRow(
                        label: "Carbs",
                        value: Int(viewModel.carbs),
                        goal: Int(viewModel.carbsGoal),
                        color: AppColor.macroCarbs
                    )
                    .animation(.easeOut(duration: 0.4), value: viewModel.carbs)

                    MacroRow(
                        label: "Fat",
                        value: Int(viewModel.fat),
                        goal: Int(viewModel.fatGoal),
                        color: AppColor.macroFat
                    )
                    .animation(.easeOut(duration: 0.4), value: viewModel.fat)
                }
                .padding(.top, AppSpace.sm)
            } else {
                collapsedSummaryView
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, AppSpace.s16)
    }
    
    private var collapsedSummaryView: some View {
        capsuleSummaryWithGoals
    }
    
    // MARK: - Capsule Variants (Indicator-Left Design)
    
    private var capsuleSummarySimple: some View {
        HStack(spacing: 12) {
            indicatorCapsule(
                label: "P",
                current: Int(viewModel.protein),
                target: nil,
                color: AppColor.macroProtein
            )
            indicatorCapsule(
                label: "C",
                current: Int(viewModel.carbs),
                target: nil,
                color: AppColor.macroCarbs
            )
            indicatorCapsule(
                label: "F",
                current: Int(viewModel.fat),
                target: nil,
                color: AppColor.macroFat
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var capsuleSummaryWithGoals: some View {
        HStack(spacing: 12) {
            indicatorCapsule(
                label: "P",
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal),
                color: AppColor.macroProtein
            )
            indicatorCapsule(
                label: "C",
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal),
                color: AppColor.macroCarbs
            )
            indicatorCapsule(
                label: "F",
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal),
                color: AppColor.macroFat
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var capsuleSummaryWithGoalsAndProgress: some View {
        HStack(spacing: 12) {
            progressIndicatorCapsule(
                label: "P",
                color: AppColor.macroProtein,
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal)
            )
            progressIndicatorCapsule(
                label: "C",
                color: AppColor.macroCarbs,
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal)
            )
            progressIndicatorCapsule(
                label: "F",
                color: AppColor.macroFat,
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var capsuleSummaryProgressHighContrast: some View {
        HStack(spacing: 12) {
            progressIndicatorCapsuleHighContrast(
                label: "P",
                color: AppColor.macroProtein,
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal)
            )
            progressIndicatorCapsuleHighContrast(
                label: "C",
                color: AppColor.macroCarbs,
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal)
            )
            progressIndicatorCapsuleHighContrast(
                label: "F",
                color: AppColor.macroFat,
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var capsuleSummaryProgressGradient: some View {
        HStack(spacing: 12) {
            progressIndicatorCapsuleGradient(
                label: "P",
                color: AppColor.macroProtein,
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal)
            )
            progressIndicatorCapsuleGradient(
                label: "C",
                color: AppColor.macroCarbs,
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal)
            )
            progressIndicatorCapsuleGradient(
                label: "F",
                color: AppColor.macroFat,
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private func indicatorCapsule(label: String, current: Int, target: Int?, color: Color) -> some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(color)
                .frame(width: 18, height: 6)
            
            HStack(spacing: 4) {
                Text(label)
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(color)
                
                if let target = target {
                    (Text("\(current)")
                        .font(AppFont.bodySm(12))
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColor.textTitle)
                     + Text(" / \(target)")
                        .font(AppFont.bodySm(12))
                        .foregroundStyle(AppColor.textMuted))
                } else {
                    Text("\(current)g")
                        .font(AppFont.bodySm(12))
                        .foregroundStyle(AppColor.textTitle)
                }
            }
        }
    }
    
    private func progressIndicatorCapsule(label: String, color: Color, current: Int, target: Int) -> some View {
        let ratio = target > 0 ? min(Double(current) / Double(target), 1.0) : 0
        
        return HStack(spacing: 6) {
            // Progress capsule to the left
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: 26, height: 6)
                
                Capsule()
                    .fill(color.opacity(0.8))
                    .frame(width: 26 * ratio, height: 6)
            }
            
            // Text uses primary color, not fill color
            HStack(spacing: 4) {
                Text(label)
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(color)
                (Text("\(current)")
                    .font(AppFont.bodySm(12))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
                 + Text(" / \(target)")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted))
            }
        }
    }
    
    private func progressIndicatorCapsuleHighContrast(label: String, color: Color, current: Int, target: Int) -> some View {
        let ratio = target > 0 ? min(Double(current) / Double(target), 1.0) : 0
        
        return HStack(spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .systemGray4)) // darker track for contrast
                    .frame(width: 26, height: 6)
                
                Capsule()
                    .fill(color)
                    .frame(width: 26 * ratio, height: 6)
            }
            
            HStack(spacing: 4) {
                Text(label)
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(color)
                Text("\(current)")
                    .font(AppFont.bodySm(12))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
                Text("/ \(target)")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted)
            }
        }
    }
    
    private func progressIndicatorCapsuleGradient(label: String, color: Color, current: Int, target: Int) -> some View {
        let ratio = target > 0 ? min(Double(current) / Double(target), 1.0) : 0
        let trackColor = colorScheme == .dark ? Color(uiColor: .systemGray3) : Color(uiColor: .systemGray5)
        
        return HStack(spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(width: 26, height: 6)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 26 * ratio, height: 6)
                    .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 0) // subtle inner-like shadow
            }
            
            HStack(spacing: 4) {
                Text(label)
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(color)
                Text("\(current)")
                    .font(AppFont.bodySm(12))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
                Text("/ \(target)")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted)
            }
        }
    }
    
    // MARK: - Badge Variants
    
    private var badgeFillSummaryView: some View {
        HStack(spacing: 8) {
            badgeFillChip(
                label: "P",
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal),
                color: AppColor.macroProtein,
                boldActual: false,
                omitUnits: false
            )
            badgeFillChip(
                label: "C",
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal),
                color: AppColor.macroCarbs,
                boldActual: false,
                omitUnits: false
            )
            badgeFillChip(
                label: "F",
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal),
                color: AppColor.macroFat,
                boldActual: false,
                omitUnits: false
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var badgeFillBoldSummaryView: some View {
        HStack(spacing: 8) {
            badgeFillChip(
                label: "P",
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal),
                color: AppColor.macroProtein,
                boldActual: true,
                omitUnits: false
            )
            badgeFillChip(
                label: "C",
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal),
                color: AppColor.macroCarbs,
                boldActual: true,
                omitUnits: false
            )
            badgeFillChip(
                label: "F",
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal),
                color: AppColor.macroFat,
                boldActual: true,
                omitUnits: false
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var badgeFillBoldNoUnitsSummaryView: some View {
        HStack(spacing: 8) {
            badgeFillChip(
                label: "P",
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal),
                color: AppColor.macroProtein,
                boldActual: true,
                omitUnits: true
            )
            badgeFillChip(
                label: "C",
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal),
                color: AppColor.macroCarbs,
                boldActual: true,
                omitUnits: true
            )
            badgeFillChip(
                label: "F",
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal),
                color: AppColor.macroFat,
                boldActual: true,
                omitUnits: true
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var badgeFillWithProgressSummaryView: some View {
        HStack(spacing: 8) {
            badgeFillWithProgress(
                label: "P",
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal),
                color: AppColor.macroProtein
            )
            badgeFillWithProgress(
                label: "C",
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal),
                color: AppColor.macroCarbs
            )
            badgeFillWithProgress(
                label: "F",
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal),
                color: AppColor.macroFat
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private var badgeLeftAccentSummaryView: some View {
        HStack(spacing: 8) {
            badgeLeftAccent(
                label: "P",
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal),
                color: AppColor.macroProtein
            )
            badgeLeftAccent(
                label: "C",
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal),
                color: AppColor.macroCarbs
            )
            badgeLeftAccent(
                label: "F",
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal),
                color: AppColor.macroFat
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private func badgeFillChip(
        label: String,
        current: Int,
        target: Int,
        color: Color,
        boldActual: Bool,
        omitUnits: Bool
    ) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(AppFont.bodySm(12))
                .foregroundStyle(color)
            
            if boldActual {
                Text("\(current)")
                    .font(AppFont.bodySm(12))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
            } else {
                Text("\(current)")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textTitle)
            }
            
            if !omitUnits {
                Text("g")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted)
            }
            
            Text("/")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textMuted)
            
            Text("\(target)")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textMuted)
            
            if !omitUnits {
                Text("g")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.15))
        )
    }
    
    private func badgeFillWithProgress(label: String, current: Int, target: Int, color: Color) -> some View {
        let ratio = target > 0 ? min(Double(current) / Double(target), 1.0) : 0
        
        return ZStack {
            // Base background (light)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.10))
            
            // Filled portion
            GeometryReader { geo in
                let width = geo.size.width
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.35))
                    .frame(width: width * ratio, alignment: .leading)
            }
            
            HStack(spacing: 4) {
                Text(label)
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(color)
                
                Text("\(current)")
                    .font(AppFont.bodySm(12))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.textTitle)
                
                Text("/ \(target)")
                    .font(AppFont.bodySm(12))
                    .foregroundStyle(AppColor.textMuted)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .frame(height: 24)
    }
    
    private func badgeLeftAccent(label: String, current: Int, target: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(AppFont.bodySm(12))
                .foregroundStyle(color)
            Text("\(current) / \(target)g")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textTitle)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(uiColor: .systemGray6))
        )
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 3)
                .frame(maxHeight: .infinity),
            alignment: .leading
        )
    }
    
    // MARK: - Line Variants
    
    @ViewBuilder
    private var verticalLinesSummaryView: some View {
        VStack(alignment: .leading, spacing: 4) {
            lineRow(
                label: "P",
                color: AppColor.macroProtein,
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal)
            )
            lineRow(
                label: "C",
                color: AppColor.macroCarbs,
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal)
            )
            lineRow(
                label: "F",
                color: AppColor.macroFat,
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal)
            )
        }
        .padding(.horizontal, AppSpace.s16)
    }
    
    private func lineRow(label: String, color: Color, current: Int, target: Int) -> some View {
        let progress = target > 0 ? min(Double(current) / Double(target), 1.0) : 0
        
        return HStack(spacing: 4) {
            Text(label)
                .font(AppFont.bodySm(12))
                .foregroundStyle(color)
            
            Text("\(current)")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textTitle)
            
            Text("/ \(target)")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textMuted)
            
            Spacer(minLength: 4)
            
            // Tiny line showing ratio
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .systemGray5))
                    Capsule()
                        .fill(color)
                        .frame(width: width * progress)
                }
            }
            .frame(width: 60, height: 3)
        }
    }
    
    @ViewBuilder
    private var horizontalLinesSummaryView: some View {
        HStack(spacing: 16) {
            horizontalLineItem(
                label: "P",
                color: AppColor.macroProtein,
                current: Int(viewModel.protein),
                target: Int(viewModel.proteinGoal)
            )
            horizontalLineItem(
                label: "C",
                color: AppColor.macroCarbs,
                current: Int(viewModel.carbs),
                target: Int(viewModel.carbsGoal)
            )
            horizontalLineItem(
                label: "F",
                color: AppColor.macroFat,
                current: Int(viewModel.fat),
                target: Int(viewModel.fatGoal)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpace.s16)
    }
    
    private func horizontalLineItem(
        label: String,
        color: Color,
        current: Int,
        target: Int
    ) -> some View {
        let progress = target > 0 ? min(Double(current) / Double(target), 1.0) : 0
        
        return HStack(spacing: 4) {
            Text(label)
                .font(AppFont.bodySm(12))
                .foregroundStyle(color)
            
            Text("\(current)")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textTitle)
            
            Text("/ \(target)")
                .font(AppFont.bodySm(12))
                .foregroundStyle(AppColor.textMuted)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(uiColor: .systemGray5))
                Capsule()
                    .fill(color)
                    .frame(width: 24 * progress)
            }
            .frame(width: 24, height: 3)
        }
    }
}

#Preview {
    MacrosSectionView()
        .environmentObject(TodayViewModel())
        .background(AppColor.bgScreen)
}

