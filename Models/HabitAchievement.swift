import Foundation

struct HabitAchievementProgress: Codable {
    var hasTakenFirstStep = false
    var currentStreak = 0
    var lastActiveDay = ""
    var hasWeekStreak = false
    var hasMonthStreak = false
    var hasPerfectDay = false
}

enum HabitAchievement: String, CaseIterable, Identifiable {
    case firstStep
    case weekStreak
    case monthStreak
    case perfectDay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstStep: "Первый шаг"
        case .weekStreak: "Неделя силы"
        case .monthStreak: "Марафонец"
        case .perfectDay: "Перфекционист"
        }
    }

    var symbol: String {
        switch self {
        case .firstStep: "figure.walk"
        case .weekStreak: "flame.fill"
        case .monthStreak: "figure.run"
        case .perfectDay: "star.fill"
        }
    }

    func isUnlocked(_ progress: HabitAchievementProgress) -> Bool {
        switch self {
        case .firstStep: progress.hasTakenFirstStep
        case .weekStreak: progress.hasWeekStreak
        case .monthStreak: progress.hasMonthStreak
        case .perfectDay: progress.hasPerfectDay
        }
    }
}
