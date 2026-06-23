import Foundation

/// Re-validate every entry in a loaded bundle through the solver: each must be
/// `.unique` with `guesses == 0` and its solver loop must match the region's
/// derived loop. Mirrors `auditPuzzle` but labels by id.
public func auditBundle(_ bundle: PuzzleBundle) -> [PoolReport] {
    var out: [PoolReport] = []
    for tier in Tier.allCases {
        for dp in bundle.puzzles(for: tier) {
            out.append(auditPuzzle(dp.puzzle, label: "\(tier.rawValue):\(dp.id)"))
        }
    }
    return out
}
