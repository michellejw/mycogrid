import Foundation
import SwiftUI

enum DrawMode: String, Codable, Sendable {
    case draw
    case mark
}

/// Runtime state for a single puzzle session.
@MainActor
@Observable
final class Board {
    let model: PuzzleModel
    let groveNumber: Int
    let tier: Tier?
    let allowHints: Bool

    var activeEdges: Set<Edge>
    var xEdges: Set<Edge>
    var mode: DrawMode = .draw
    var elapsedSeconds: Int = 0
    var hintsUsed: Int = 0
    var hintLevel: Int = 0
    var highlightCell: Cell? = nil
    var hintMessage: String? = nil

    var isSolved: Bool = false
    var solveTick: Int = 0
    var tapTick: Int = 0

    init(puzzle: Puzzle, tier: Tier?, groveNumber: Int, allowHints: Bool = true) {
        self.model = PuzzleModel(puzzle)
        self.tier = tier
        self.groveNumber = groveNumber
        self.allowHints = allowHints
        self.activeEdges = puzzle.presetActive
        self.xEdges = []
    }

    /// Build a board from a saved snapshot. Falls back to grove 0 if the saved
    /// grove number no longer exists in the tier's puzzle list (puzzles may
    /// have been re-ordered between launches).
    convenience init?(restoring progress: PuzzleProgress) {
        let puzzles = PuzzleData.puzzles(for: progress.tier)
        guard !puzzles.isEmpty else { return nil }
        let index = max(0, min(progress.groveNumber - 1, puzzles.count - 1))
        self.init(
            puzzle: puzzles[index],
            tier: progress.tier,
            groveNumber: index + 1,
            allowHints: true
        )
        self.activeEdges = Set(progress.activeEdges)
        self.xEdges = Set(progress.xEdges)
        self.mode = progress.mode
        self.elapsedSeconds = progress.elapsedSeconds
        self.hintsUsed = progress.hintsUsed
        // Re-run win detection in case the restored state already satisfies.
        if model.isSolved(active: activeEdges) {
            isSolved = true
        }
    }

    /// A serializable snapshot of the current play session, or `nil` if this is
    /// a tutorial board (no tier).
    func snapshot() -> PuzzleProgress? {
        guard let tier else { return nil }
        return PuzzleProgress(
            tier: tier,
            groveNumber: groveNumber,
            activeEdges: Array(activeEdges),
            xEdges: Array(xEdges),
            mode: mode,
            elapsedSeconds: elapsedSeconds,
            hintsUsed: hintsUsed
        )
    }

    var totalHints: Int { 3 }
    var hintsRemaining: Int { max(0, totalHints - hintsUsed) }

    var puzzle: Puzzle { model.puzzle }

    func tick() {
        guard !isSolved else { return }
        elapsedSeconds += 1
    }

    func toggle(_ edge: Edge) {
        guard !isSolved else { return }
        clearHint()
        tapTick &+= 1
        switch mode {
        case .draw:
            if activeEdges.contains(edge) {
                activeEdges.remove(edge)
            } else {
                activeEdges.insert(edge)
                xEdges.remove(edge)
            }
        case .mark:
            if xEdges.contains(edge) {
                xEdges.remove(edge)
            } else {
                xEdges.insert(edge)
                activeEdges.remove(edge)
            }
        }
        if model.isSolved(active: activeEdges) {
            isSolved = true
            solveTick &+= 1
        }
    }

    // MARK: Hints

    /// Tap the hint button: highlight → name → place an edge. Resets when the
    /// player makes another move (via `clearHint`).
    func nextHint() {
        guard allowHints, hintsRemaining > 0 else { return }
        hintLevel += 1
        switch hintLevel {
        case 1:
            if let cell = unsatisfiedCell() {
                highlightCell = cell
                hintMessage = nil
            } else {
                hintLevel = 3
                placeOneMissingEdge()
                hintsUsed += 1
            }
        case 2:
            hintMessage = "This area needs another move."
        default:
            placeOneMissingEdge()
            hintsUsed += 1
            hintLevel = 0
            highlightCell = nil
            hintMessage = nil
        }
    }

    private func clearHint() {
        highlightCell = nil
        hintMessage = nil
        hintLevel = 0
    }

    /// First clue cell whose current count doesn't match its target.
    private func unsatisfiedCell() -> Cell? {
        let p = model.puzzle
        for r in 0..<p.rows {
            for c in 0..<p.cols {
                let cell = Cell(c: c, r: r)
                guard let target = model.clues[cell] else { continue }
                if p.hideClues.contains(cell) { continue }
                let count = model.count(cell: cell, in: activeEdges)
                if count != target {
                    return cell
                }
            }
        }
        // Fall back to a hidden cell that's unsatisfied (rare).
        for r in 0..<p.rows {
            for c in 0..<p.cols {
                let cell = Cell(c: c, r: r)
                guard let target = model.clues[cell] else { continue }
                let count = model.count(cell: cell, in: activeEdges)
                if count != target { return cell }
            }
        }
        return nil
    }

    /// Add one edge that's in the solution but missing from the player's loop,
    /// or remove one that's wrongly present.
    private func placeOneMissingEdge() {
        // Prefer adding a missing solution edge near an unsatisfied highlighted cell.
        let p = model.puzzle
        if let cell = highlightCell ?? unsatisfiedCell() {
            // Try the cell's own edges first.
            let cellEdges = Edge.cellEdges(c: cell.c, r: cell.r)
            for e in cellEdges where model.solution.contains(e) && !activeEdges.contains(e) {
                activeEdges.insert(e)
                xEdges.remove(e)
                if model.isSolved(active: activeEdges) {
                    isSolved = true
                    solveTick &+= 1
                }
                return
            }
            // Remove a wrongly-active edge on the cell.
            for e in cellEdges where !model.solution.contains(e) && activeEdges.contains(e) {
                activeEdges.remove(e)
                return
            }
        }
        // Global fallback: add the first missing solution edge anywhere.
        for e in model.solution where !activeEdges.contains(e) {
            activeEdges.insert(e)
            xEdges.remove(e)
            if model.isSolved(active: activeEdges) {
                isSolved = true
                solveTick &+= 1
            }
            return
        }
        // Or remove the first wrong edge.
        for e in activeEdges where !model.solution.contains(e) {
            activeEdges.remove(e)
            return
        }
        _ = p
    }

    // MARK: Reset

    func reset() {
        activeEdges = puzzle.presetActive
        xEdges = []
        mode = .draw
        elapsedSeconds = 0
        hintsUsed = 0
        clearHint()
        isSolved = false
    }
}
