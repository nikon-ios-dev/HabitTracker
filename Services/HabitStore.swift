import Combine
import Foundation

@MainActor
final class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit]
    @Published private(set) var achievementProgress: HabitAchievementProgress

    private let defaults: UserDefaults
    private let habitsKey = "habits"
    private let completionDayKey = "habitsCompletionDay"
    private let achievementProgressKey = "habitAchievementProgress"

    private static let defaultHabits = [
        Habit(title: "Выпить воды"),
        Habit(title: "Сделать зарядку"),
        Habit(title: "Прочитать книгу")
    ]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.habits = Self.loadHabits(from: defaults)
        self.achievementProgress = Self.loadAchievementProgress(from: defaults)
        prepareHabitsForToday()
    }

    var completedHabitsCount: Int {
        habits.filter(\.isCompleted).count
    }

    var pendingHabitsCount: Int {
        habits.count - completedHabitsCount
    }

    var completionProgress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedHabitsCount) / Double(habits.count)
    }

    var currentStreak: Int {
        let today = Self.dayKey(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            .map(Self.dayKey(for:)) ?? ""
        return achievementProgress.lastActiveDay == today
            || achievementProgress.lastActiveDay == yesterday
            ? achievementProgress.currentStreak
            : 0
    }

    var brokenStreak: Int {
        guard currentStreak == 0,
              !achievementProgress.lastActiveDay.isEmpty else {
            return 0
        }
        return achievementProgress.currentStreak
    }

    func prepareHabitsForToday() {
        let today = Self.dayKey(for: Date())
        guard let storedDay = defaults.string(forKey: completionDayKey) else {
            defaults.set(today, forKey: completionDayKey)
            return
        }
        guard storedDay != today else { return }

        habits = habits.map { habit in
            var updatedHabit = habit
            updatedHabit.isCompleted = false
            return updatedHabit
        }
        saveHabits()
        defaults.set(today, forKey: completionDayKey)
    }

    func addHabit(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        habits.append(Habit(title: trimmedTitle))
        saveHabits()
    }

    func toggleHabit(id: Habit.ID, isCompleted: Bool) -> Bool {
        prepareHabitsForToday()
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return false }

        let hadCompletedGoal = !habits.isEmpty && habits.allSatisfy(\.isCompleted)
        habits[index].isCompleted = isCompleted
        saveHabits()

        if isCompleted {
            recordCompletion(isPerfect: habits.allSatisfy(\.isCompleted))
        }

        return !hadCompletedGoal
            && !habits.isEmpty
            && habits.allSatisfy(\.isCompleted)
    }

    func deleteHabits(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) where habits.indices.contains(index) {
            habits.remove(at: index)
        }
        saveHabits()
    }

    func isAchievementUnlocked(_ achievement: HabitAchievement) -> Bool {
        achievement.isUnlocked(achievementProgress)
    }

    func achievementDescription(for achievement: HabitAchievement) -> String {
        if isAchievementUnlocked(achievement) {
            return "Достижение открыто"
        }

        switch achievement {
        case .firstStep:
            return "Отметьте любую привычку"
        case .weekStreak:
            return "Серия: \(currentStreak) из 7 дней подряд"
        case .monthStreak:
            return "Серия: \(currentStreak) из 30 дней подряд"
        case .perfectDay:
            return "Выполните все привычки за день"
        }
    }

    private func recordCompletion(isPerfect: Bool) {
        let today = Self.dayKey(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            .map(Self.dayKey(for:)) ?? ""

        achievementProgress.hasTakenFirstStep = true
        if achievementProgress.lastActiveDay != today {
            achievementProgress.currentStreak = achievementProgress.lastActiveDay == yesterday
                ? achievementProgress.currentStreak + 1
                : 1
            achievementProgress.lastActiveDay = today
        }

        achievementProgress.hasWeekStreak =
            achievementProgress.hasWeekStreak || achievementProgress.currentStreak >= 7
        achievementProgress.hasMonthStreak =
            achievementProgress.hasMonthStreak || achievementProgress.currentStreak >= 30
        achievementProgress.hasPerfectDay = achievementProgress.hasPerfectDay || isPerfect
        saveAchievementProgress()
    }

    private func saveHabits() {
        do {
            defaults.set(try JSONEncoder().encode(habits), forKey: habitsKey)
        } catch {
            assertionFailure("Не удалось сохранить привычки: \(error)")
        }
    }

    private func saveAchievementProgress() {
        do {
            defaults.set(
                try JSONEncoder().encode(achievementProgress),
                forKey: achievementProgressKey
            )
        } catch {
            assertionFailure("Не удалось сохранить достижения: \(error)")
        }
    }

    private static func loadHabits(from defaults: UserDefaults) -> [Habit] {
        guard let data = defaults.data(forKey: "habits") else {
            return defaultHabits
        }

        do {
            return try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            assertionFailure("Не удалось загрузить привычки: \(error)")
            return []
        }
    }

    private static func loadAchievementProgress(from defaults: UserDefaults) -> HabitAchievementProgress {
        guard let data = defaults.data(forKey: "habitAchievementProgress") else {
            return HabitAchievementProgress()
        }

        do {
            return try JSONDecoder().decode(HabitAchievementProgress.self, from: data)
        } catch {
            assertionFailure("Не удалось загрузить достижения: \(error)")
            return HabitAchievementProgress()
        }
    }

    private static func dayKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}
