import Foundation

enum MainTab: String, CaseIterable {
    case today
    case weekly
    case profile

    var title: String {
        switch self {
        case .today: return "Today"
        case .weekly: return "Weekly"
        case .profile: return "Profile"
        }
    }

    var systemImageName: String {
        switch self {
        case .today: return "house.fill"
        case .weekly: return "chart.bar.xaxis"
        case .profile: return "person.crop.circle"
        }
    }
}

