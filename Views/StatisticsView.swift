import Charts
import SwiftUI

struct StatisticsView: View {
    @ObservedObject var store: HabitStore

    private var statistics: [HabitDailyStatistic] {
        store.lastSevenDaysStatistics
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                summary
                completedHabitsChart
                completionRateChart
            }
            .padding()
        }
        .navigationTitle("Статистика")
    }

    private var summary: some View {
        HStack(spacing: 12) {
            summaryValue(
                title: "Сегодня",
                value: "\(store.completedHabitsCount) из \(store.habits.count)"
            )
            summaryValue(
                title: "Текущая серия",
                value: "\(store.currentStreak) дн."
            )
        }
    }

    private func summaryValue(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    private var completedHabitsChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Выполнено привычек")
                .font(.headline)

            Chart(statistics) { statistic in
                BarMark(
                    x: .value("День", statistic.day, unit: .day),
                    y: .value("Выполнено", statistic.completedCount)
                )
                .foregroundStyle(Color.orange.gradient)
                .cornerRadius(5)
            }
            .chartXScale(domain: chartDateRange)
            .chartYScale(domain: 0...max(statistics.map(\.completedCount).max() ?? 0, 1))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 210)
            .accessibilityLabel("Столбчатый график количества выполненных привычек за последние семь дней")
        }
    }

    private var completionRateChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Доля выполненного")
                .font(.headline)

            Chart(statistics) { statistic in
                AreaMark(
                    x: .value("День", statistic.day, unit: .day),
                    y: .value("Выполнение", statistic.completionRate)
                )
                .foregroundStyle(Color.green.opacity(0.16).gradient)

                LineMark(
                    x: .value("День", statistic.day, unit: .day),
                    y: .value("Выполнение", statistic.completionRate)
                )
                .foregroundStyle(Color.green)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("День", statistic.day, unit: .day),
                    y: .value("Выполнение", statistic.completionRate)
                )
                .foregroundStyle(Color.green)
            }
            .chartXScale(domain: chartDateRange)
            .chartYScale(domain: 0...1)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 0.25, 0.5, 0.75, 1.0]) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: FloatingPointFormatStyle<Double>.Percent())
                }
            }
            .frame(height: 210)
            .accessibilityLabel("Линейный график процента выполненных привычек за последние семь дней")
        }
    }

    private var chartDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let firstDay = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let lastDay = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        return firstDay...lastDay
    }
}
