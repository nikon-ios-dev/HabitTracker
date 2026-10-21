import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedIcon = HabitIcon.defaultName

    let onSave: (String, String) -> Void

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 16) {
            TextField("Название привычки", text: $title)
                .textFieldStyle(.roundedBorder)

            Text("Выбери значок")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(HabitIcon.options, id: \.self) { iconName in
                    Button {
                        selectedIcon = iconName
                    } label: {
                        Image(systemName: iconName)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .foregroundStyle(selectedIcon == iconName ? Color.white : Color.accentColor)
                            .background {
                                if selectedIcon == iconName {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(iconName)
                    .accessibilityAddTraits(selectedIcon == iconName ? .isSelected : [])
                }
            }

            Button("Сохранить") {
                onSave(trimmedTitle, selectedIcon)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmedTitle.isEmpty)
        }
        .padding()
        .presentationDetents([.height(360)])
    }
}
