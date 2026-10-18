import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    let onSave: (String) -> Void

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 16) {
            TextField("Название привычки", text: $title)
                .textFieldStyle(.roundedBorder)

            Button("Сохранить") {
                onSave(trimmedTitle)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmedTitle.isEmpty)
        }
        .padding()
        .presentationDetents([.height(180)])
    }
}
