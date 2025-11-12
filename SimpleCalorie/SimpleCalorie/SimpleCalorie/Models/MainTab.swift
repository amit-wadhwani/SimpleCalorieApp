import Foundation

enum MainTab: String, CaseIterable {
    case today
    case weekly
    case settings

    var title: String {
        switch self {
        case .today: return "Today"
        case .weekly: return "Weekly"
        case .settings: return "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .today: return "house.fill"
        case .weekly: return "chart.bar.xaxis"
        case .settings: return "gearshape"
        }
    }
}

