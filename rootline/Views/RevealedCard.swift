import SwiftUI
import ShroomKit

/// Shown when the player chose "Show solution". Quieter than `WinCard` — no
/// checkmark, no celebration, no time — since this isn't a clear.
struct RevealedCard: View {
    let board: Board
    let onNext: () -> Void
    let onMenu: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(palette.pill)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "eye.fill")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(palette.sub)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Solution shown")
                        .font(.system(.callout, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.text)
                    Text(subtitle)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(palette.sub)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 10) {
                Button(action: onMenu) {
                    Text("Menu")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.text)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.tierBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(palette.tierBorder, lineWidth: 1)
                                )
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button(action: onNext) {
                    Text("Next puzzle")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.accent)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.pill)
        )
    }

    private var subtitle: String {
        let tierLabel = board.tier?.label ?? "Lesson"
        let size = "\(board.puzzle.cols)×\(board.puzzle.rows)"
        return "\(tierLabel) · \(size)"
    }
}
