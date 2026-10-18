import Combine
import Foundation
import UserNotifications

@MainActor
final class HabitReminderScheduler: ObservableObject {
    @Published var alertMessage: String?

    private let center = UNUserNotificationCenter.current()
    private let notificationID = "daily-incomplete-habits-reminder"
    private var hasShownPermissionNotice = false

    func updateReminder(pendingHabitsCount: Int) async {
        guard pendingHabitsCount > 0 else {
            center.removePendingNotificationRequests(withIdentifiers: [notificationID])
            return
        }

        do {
            var settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                let isAuthorized = try await center.requestAuthorization(options: [.alert, .sound])
                guard isAuthorized else {
                    showPermissionNotice()
                    return
                }
                settings = await center.notificationSettings()
            }

            guard isAuthorized(settings.authorizationStatus) else {
                showPermissionNotice()
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Привычки"
            content.body = reminderText(for: pendingHabitsCount)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(hour: 20, minute: 0),
                repeats: true
            )
            let request = UNNotificationRequest(
                identifier: notificationID,
                content: content,
                trigger: trigger
            )
            try await center.add(request)
        } catch {
            alertMessage = "Не удалось настроить напоминание: \(error.localizedDescription)"
        }
    }

    func dismissAlert() {
        alertMessage = nil
    }

    private func reminderText(for count: Int) -> String {
        if count == 1 {
            return "У тебя ещё 1 невыполненная привычка!"
        }

        let lastTwoDigits = count % 100
        let lastDigit = count % 10
        let noun: String
        if (11...14).contains(lastTwoDigits) {
            noun = "невыполненных привычек"
        } else {
            switch lastDigit {
            case 2...4:
                noun = "невыполненные привычки"
            default:
                noun = "невыполненных привычек"
            }
        }
        return "У тебя ещё \(count) \(noun)!"
    }

    private func showPermissionNotice() {
        guard !hasShownPermissionNotice else { return }
        hasShownPermissionNotice = true
        alertMessage = "Разреши уведомления для приложения в настройках устройства, чтобы получать напоминания в 20:00."
    }

    private func isAuthorized(_ status: UNAuthorizationStatus) -> Bool {
        if status == .authorized || status == .provisional {
            return true
        }

        #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        return status == .ephemeral
        #else
        return false
        #endif
    }
}
