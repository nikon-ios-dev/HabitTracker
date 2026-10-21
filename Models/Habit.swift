import Foundation

struct Habit: Codable, Identifiable {
    var id = UUID()
    var title: String
    var isCompleted = false
    var iconName = HabitIcon.defaultName

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case isCompleted
        case iconName
    }

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        iconName: String = HabitIcon.defaultName
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.iconName = iconName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
            ?? HabitIcon.defaultName(for: title)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(iconName, forKey: .iconName)
    }
}

enum HabitIcon {
    nonisolated static let defaultName = "sparkles"

    static let options = [
        "sparkles",
        "drop.fill",
        "figure.run",
        "book.fill",
        "heart.fill",
        "leaf.fill",
        "bed.double.fill",
        "fork.knife",
        "pills.fill",
        "brain.head.profile",
        "dumbbell.fill",
        "sun.max.fill",
        "music.note",
        "house.fill",
        "pawprint.fill",
        "bicycle"
    ]

    static func defaultName(for title: String) -> String {
        switch title {
        case "Выпить воды":
            "drop.fill"
        case "Сделать зарядку":
            "figure.run"
        case "Прочитать книгу":
            "book.fill"
        default:
            defaultName
        }
    }
}
