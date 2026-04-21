import SwiftUI

struct ConfettiView: View {
    let seed: Int

    private var pieces: [ConfettiPiece] {
        (0..<42).map { index in
            ConfettiPiece(
                id: index,
                x: CGFloat((index * 37 + seed * 11) % 100) / 100,
                delay: Double(index % 9) * 0.11,
                size: CGFloat(6 + (index % 5) * 3),
                color: [.pink, .yellow, .mint, .orange, .cyan, .purple][index % 6]
            )
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate

                for piece in pieces {
                    let progress = CGFloat((elapsed + piece.delay).truncatingRemainder(dividingBy: 2.4) / 2.4)
                    let y = size.height * progress
                    let wobble = sin(progress * .pi * 6 + CGFloat(piece.id)) * 18
                    let rect = CGRect(
                        x: size.width * piece.x + wobble,
                        y: y - 16,
                        width: piece.size,
                        height: piece.size * 0.55
                    )

                    context.opacity = 1 - max(0, progress - 0.76) * 2.2
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 2),
                        with: .color(piece.color)
                    )
                }
            }
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id: Int
    let x: CGFloat
    let delay: Double
    let size: CGFloat
    let color: Color
}
