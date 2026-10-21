import SwiftUI

private enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: "Как в системе"
        case .light: "Светлая"
        case .dark: "Тёмная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}

struct ContentView: View {
    @StateObject private var store = HabitStore()
    @StateObject private var reminderScheduler = HabitReminderScheduler()
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue
    @State private var isShowingAddHabit = false
    @State private var isShowingConfetti = false
    @State private var confettiAnimationID = UUID()

    private let habitColors: [Color] = [
        .blue, .green, .orange, .purple, .pink, .teal, .indigo
    ]

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRawValue) ?? .system
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TimelineView(.periodic(from: .now, by: 60)) { _ in
                    StreakBanner(
                        streak: store.currentStreak,
                        brokenStreak: store.brokenStreak
                    )
                }

                VStack(spacing: 12) {
                    Text("Выполнено: \(store.completedHabitsCount) из \(store.habits.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)

                    ProgressView(value: store.completionProgress)
                        .tint(.green)
                        .animation(.easeInOut(duration: 0.35), value: store.completionProgress)
                }
                .padding()

                List {
                    AchievementsSection(store: store)

                    Section("Привычки") {
                        ForEach(Array(store.habits.enumerated()), id: \.element.id) { index, habit in
                            HabitRow(
                                habit: habit,
                                color: habitColors[index % habitColors.count]
                            ) { isCompleted in
                                let completedGoal = withAnimation(
                                    .spring(response: 0.35, dampingFraction: 0.8)
                                ) {
                                    store.toggleHabit(id: habit.id, isCompleted: isCompleted)
                                }
                                if isCompleted {
                                    AudioFeedback.playCompletionSound()
                                }
                                if completedGoal {
                                    showConfetti()
                                }
                            }
                            .transition(.opacity)
                        }
                        .onDelete(perform: deleteHabits)
                        .animation(.easeInOut(duration: 0.3), value: store.habits.map(\.id))
                    }
                }
            }
            .navigationTitle("Привычки")
            .onAppear(perform: store.prepareHabitsForToday)
            .task {
                await updateReminder()
            }
            .onChange(of: store.pendingHabitsCount) { _, _ in
                Task {
                    await updateReminder()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Menu {
                            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                Button {
                                    appearanceModeRawValue = mode.rawValue
                                } label: {
                                    if appearanceMode == mode {
                                        Label(mode.title, systemImage: "checkmark")
                                    } else {
                                        Text(mode.title)
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: appearanceMode.symbol)
                        }
                        .accessibilityLabel("Тема оформления: \(appearanceMode.title)")

                        NavigationLink {
                            StatisticsView(store: store)
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                        }
                        .accessibilityLabel("Статистика")

                        Button {
                            isShowingAddHabit = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Добавить привычку")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddHabit) {
                AddHabitSheet { title, iconName in
                    store.addHabit(title: title, iconName: iconName)
                }
            }
            .overlay {
                if isShowingConfetti {
                    ConfettiOverlay()
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }
            .alert(
                "Напоминания",
                isPresented: Binding(
                    get: { reminderScheduler.alertMessage != nil },
                    set: { if !$0 { reminderScheduler.dismissAlert() } }
                )
            ) {
                Button("Понятно", role: .cancel) {
                    reminderScheduler.dismissAlert()
                }
            } message: {
                Text(reminderScheduler.alertMessage ?? "")
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
    }

    private func updateReminder() async {
        await reminderScheduler.updateReminder(
            pendingHabitsCount: store.pendingHabitsCount
        )
    }

    private func showConfetti() {
        let animationID = UUID()
        confettiAnimationID = animationID
        withAnimation(.easeIn(duration: 0.2)) {
            isShowingConfetti = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            guard confettiAnimationID == animationID else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                isShowingConfetti = false
            }
        }
    }

    private func deleteHabits(at offsets: IndexSet) {
        withAnimation(.easeInOut(duration: 0.3)) {
            store.deleteHabits(at: offsets)
        }
    }
}

#Preview {
    ContentView()
}