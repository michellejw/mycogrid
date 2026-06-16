import SwiftUI
import ShroomKit

/// The Rootline mark: a small closed loop forming a tidy mycelium glyph.
/// Drawn from a hand-curated puzzle region so it is, literally, the game.
struct MyceliumIcon: View {
    @Environment(\.palette) private var palette
    var glow: Bool = true

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            Canvas { ctx, canvasSize in
                let pad = size * 0.16
                let inner = size - pad * 2
                let cell = inner / 4

                // The path traces a stylised loop that reads as a branching root.
                let points: [(Int, Int)] = [
                    (1, 0), (2, 0), (2, 1), (3, 1),
                    (3, 2), (4, 2), (4, 3), (3, 3),
                    (3, 4), (1, 4), (1, 3), (0, 3),
                    (0, 1), (1, 1), (1, 0)
                ]
                var path = Path()
                var first = true
                for (cx, ry) in points {
                    let p = CGPoint(
                        x: pad + CGFloat(cx) * cell,
                        y: pad + CGFloat(ry) * cell
                    )
                    if first {
                        path.move(to: p)
                        first = false
                    } else {
                        path.addLine(to: p)
                    }
                }
                path.closeSubpath()

                let stroke = size * 0.085
                ctx.stroke(
                    path,
                    with: .color(palette.accent),
                    style: StrokeStyle(lineWidth: stroke, lineCap: .round, lineJoin: .round)
                )

                // Junction dots at three corners.
                let dots: [(Int, Int)] = [(1, 0), (3, 2), (1, 4)]
                let dotR = size * 0.055
                for (cx, ry) in dots {
                    let p = CGPoint(
                        x: pad + CGFloat(cx) * cell,
                        y: pad + CGFloat(ry) * cell
                    )
                    let rect = CGRect(x: p.x - dotR, y: p.y - dotR, width: dotR * 2, height: dotR * 2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(palette.accent))
                }
                _ = canvasSize
            }
            .modifier(IconGlow(color: palette.accent, enabled: glow))
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}

private struct IconGlow: ViewModifier {
    let color: Color
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            content
                .shadow(color: color.opacity(0.75), radius: 3)
                .shadow(color: color.opacity(0.45), radius: 8)
        } else {
            content
        }
    }
}
