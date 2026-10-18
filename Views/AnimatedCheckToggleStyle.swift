import SwiftUI

struct AnimatedCheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                    configuration.isOn.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(
                            configuration.isOn ? Color.green : Color.gray.opacity(0.5),
                            lineWidth: 2
                        )
                        .background(Circle().fill(configuration.isOn ? Color.green : Color.clear))

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(configuration.isOn ? 1 : 0.3)
                        .opacity(configuration.isOn ? 1 : 0)
                }
                .frame(width: 26, height: 26)
                .scaleEffect(configuration.isOn ? 1 : 0.92)
                .animation(.spring(response: 0.3, dampingFraction: 0.55), value: configuration.isOn)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(configuration.isOn ? "Отмечено" : "Не отмечено")
        }
        .contentShape(Rectangle())
    }
}
