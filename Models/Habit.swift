import Foundation

struct Habit: Codable, Identifiable {
    var id = UUID()
    var title: String
    var isCompleted = false
}
