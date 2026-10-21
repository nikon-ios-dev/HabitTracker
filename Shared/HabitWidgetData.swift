import Foundation
import WidgetKit

struct HabitWidgetProgress {
    let completedCount: Int
    let totalCount: Int
    let updatedAt: Date

    var fractionCompleted: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    static let empty = HabitWidgetProgress(
        completedCount: 0,
        totalCount: 0,
        updatedAt: .now
    )
}

enum HabitWidgetData {
    static let appGroupIdentifier = "group.com.nikon.habitracker"

    private static let completedCountKey = "widgetCompletedHabitCount"
    private static let totalCountKey = "widgetTotalHabitCount"
    private static let updatedAtKey = "widgetProgressUpdatedAt"

    static func read() -> HabitWidgetProgress {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return .empty
        }

        return HabitWidgetProgress(
            completedCount: defaults.integer(forKey: completedCountKey),
            totalCount: defaults.integer(forKey: totalCountKey),
            updatedAt: defaults.object(forKey: updatedAtKey) as? Date ?? .now
        )
    }

    static func publish(completedCount: Int, totalCount: Int) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            NSLog(
                "Habit widget progress was not shared. Configure the same App Group in both targets and HabitWidgetData.swift."
            )
            return
        }

        defaults.set(completedCount, forKey: completedCountKey)
        defaults.set(totalCount, forKey: totalCountKey)
        defaults.set(Date(), forKey: updatedAtKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
