import SwiftUI

struct ConfettiOverlay: View {
    @State private var isAnimating = false

    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow, .red]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<36, id: \.self) { index in
                let endX = CGFloat((index * 47) % 100) / 100 * geometry.size.width
                let endY = geometry.size.height * (0.3 + CGFloat((index * 31) % 60) / 100)

                RoundedRectangle(cornerRadius: 2)
                    .fill(colors[index % colors.count])
                    .frame(width: 8, height: 12)
                    .rotationEffect(.degrees(isAnimating ? Double((index * 79) % 720) : 0))
                    .position(
                        x: isAnimating ? endX : geometry.size.width / 2,
                        y: isAnimating ? endY : geometry.size.height * 0.2
                    )
                    .animation(
                        .easeOut(duration: 1.3).delay(Double(index % 8) * 0.025),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
