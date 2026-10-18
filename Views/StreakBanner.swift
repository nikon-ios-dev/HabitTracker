import SwiftUI

struct StreakBanner: View {
    let streak: Int
    let brokenStreak: Int

    private var isBroken: Bool {
        brokenStreak > 0
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isBroken ? "flame" : "flame.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(isBroken ? Color.gray : Color.orange)
                .symbolEffect(.pulse, options: .repeating, isActive: streak > 0 && !isBroken)
                .scaleEffect(isBroken ? 0.72 : 1)
                .rotationEffect(.degrees(isBroken ? -18 : 0))
                .opacity(isBroken ? 0.45 : 1)
                .overlay(alignment: .topTrailing) {
                    if isBroken {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(.gray.opacity(0.75))
                            .offset(x: 9, y: -8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeOut(duration: 0.8), value: isBroken)

            VStack(alignment: .leading, spacing: 4) {
                if isBroken {
                    Text("Серия прервана")
                        .font(.title2.bold())
                    Text("Было \(dayCount(brokenStreak)) подряд. Зажги огонь снова!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if streak > 0 {
                    Text("\(streak) \(dayCount(streak)) подряд!")
                        .font(.title2.bold())
                    Text("Продолжай в том же духе")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Начни серию сегодня!")
                        .font(.title2.bold())
                    Text("Отметь привычку, чтобы зажечь огонь")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            (isBroken ? Color.gray : Color.orange)
                .opacity(0.12),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .padding(.horizontal)
        .padding(.top, 8)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: streak)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: brokenStreak)
    }

    private func dayCount(_ count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = count % 10

        if (11...14).contains(lastTwoDigits) {
            return "\(count) дней"
        }
        switch lastDigit {
        case 1:
            return "\(count) день"
        case 2...4:
            return "\(count) дня"
        default:
            return "\(count) дней"
        }
    }
}
