import SwiftUI
import ShroomKit

struct WinCard: View {
    let board: Board
    /// True when this clear beat a pre-existing best time for the tier.
    let fastestYet: Bool
    let onMenu: () -> Void
    let onArchive: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        ResultCard(
            title: "Network connected!",
            subtitle: subtitle,
            note: fastestYet ? "Your fastest yet" : nil,
            primaryLabel: "Done", onPrimary: onMenu,
            secondaryLabel: "Archive", onSecondary: onArchive
        ) {
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(palette.tierSelBg)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(palette.accent)
                )
        }
    }

    private var subtitle: String {
        let tierLabel = board.tier?.label ?? "Lesson"
        let size = "\(board.puzzle.cols)×\(board.puzzle.rows)"
        let time = board.elapsedSeconds.asTimerString
        return "\(tierLabel) · \(size) · cleared in \(time)"
    }
}
