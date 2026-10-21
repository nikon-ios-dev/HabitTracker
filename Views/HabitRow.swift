import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let color: Color
    let onChange: (Bool) -> Void

    var body: some View {
        Toggle(
            isOn: Binding(
                get: { habit.isCompleted },
                set: onChange
            )
        ) {
            HStack(spacing: 10) {
                Image(systemName: habit.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.12), in: Circle())

                Text(habit.title)
                    .foregroundStyle(habit.isCompleted ? Color.secondary : color)
                    .strikethrough(habit.isCompleted)
            }
        }
        .toggleStyle(AnimatedCheckToggleStyle())
    }
}
