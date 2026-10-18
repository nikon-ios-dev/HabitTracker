import SwiftUI

struct AchievementsSection: View {
    let store: HabitStore

    var body: some View {
        Section("Достижения") {
            ForEach(HabitAchievement.allCases) { achievement in
                let unlocked = store.isAchievementUnlocked(achievement)

                HStack(spacing: 12) {
                    Image(systemName: unlocked ? achievement.symbol : "lock.fill")
                        .foregroundStyle(unlocked ? Color.orange : Color.secondary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(achievement.title)
                            .fontWeight(unlocked ? .semibold : .regular)
                        Text(store.achievementDescription(for: achievement))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
