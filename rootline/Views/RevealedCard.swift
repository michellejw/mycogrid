import SwiftUI
import ShroomKit

/// Shown when the player chose "Show solution". Quieter than `WinCard` — no
/// checkmark, no celebration, no time — since this isn't a clear.
struct RevealedCard: View {
    let board: Board
    let onMenu: () -> Void
    let onArchive: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        ResultCard(
            title: "Solution shown",
            subtitle: subtitle,
            primaryLabel: "Done", onPrimary: onMenu,
            secondaryLabel: "Archive", onSecondary: onArchive
        ) {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(palette.pill)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "eye.fill")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(palette.sub)
                )
        }
    }

    private var subtitle: String {
        let tierLabel = board.tier?.label ?? "Lesson"
        let size = "\(board.puzzle.cols)×\(board.puzzle.rows)"
        return "\(tierLabel) · \(size)"
    }
}
