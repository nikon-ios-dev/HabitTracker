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
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)

                Text(habit.title)
                    .foregroundStyle(habit.isCompleted ? Color.gray : color)
                    .strikethrough(habit.isCompleted)
            }
        }
        .toggleStyle(AnimatedCheckToggleStyle())
    }
}
