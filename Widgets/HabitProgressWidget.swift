import SwiftUI
import WidgetKit

private struct HabitProgressEntry: TimelineEntry {
    let date: Date
    let completedCount: Int
    let totalCount: Int

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

private struct HabitProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitProgressEntry {
        HabitProgressEntry(date: .now, completedCount: 2, totalCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitProgressEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitProgressEntry>) -> Void) {
        let entry = makeEntry()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func makeEntry() -> HabitProgressEntry {
        let progress = HabitWidgetData.read()
        return HabitProgressEntry(
            date: progress.updatedAt,
            completedCount: progress.completedCount,
            totalCount: progress.totalCount
        )
    }
}

private struct HabitProgressWidgetView: View {
    let entry: HabitProgressEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Привычки", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }

            ProgressView(value: entry.progress)
                .tint(.green)

            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }

    private var statusText: String {
        guard entry.totalCount > 0 else {
            return "Добавь привычки, чтобы начать"
        }
        if entry.completedCount == entry.totalCount {
            return "Все привычки выполнены!"
        }
        return "Выполнено сегодня"
    }
}

@main
struct HabitProgressWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "HabitProgressWidget",
            provider: HabitProgressProvider()
        ) { entry in
            HabitProgressWidgetView(entry: entry)
        }
        .configurationDisplayName("Прогресс привычек")
        .description("Показывает, сколько привычек выполнено сегодня.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
