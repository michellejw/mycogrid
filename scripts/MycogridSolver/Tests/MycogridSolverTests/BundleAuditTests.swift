// scripts/MycogridSolver/Tests/MycogridSolverTests/BundleAuditTests.swift
import Testing
import Foundation
@testable import MycogridSolver

@Suite struct BundleAuditTests {
    /// Build a one-entry bundle from a known-good hand puzzle (Sprout grove #1,
    /// all clues shown) so the audit must pass.
    @Test func auditPassesForAValidEntry() {
        let p = Puzzle(cols: 4, rows: 6, inside: [
            [1,0],[2,0],
            [0,1],[1,1],[2,1],[3,1],
            [0,2],[1,2],[2,2],[3,2],
            [0,3],[1,3],[2,3],[3,3],
            [0,4],[1,4],[2,4],[3,4],
            [1,5],[2,5]
        ])
        let dp = DailyPuzzle(id: "x", tier: .sprout, puzzle: p)
        let bundle = PuzzleBundle(byTier: [.sprout: [dp]])
        let reports = auditBundle(bundle)
        #expect(reports.count == 1)
        #expect(reports[0].passed)
        #expect(reports[0].guesses == 0)
    }

    @Test func auditFlagsANonUniqueEntry() {
        // All clues hidden on a 2x2 → no visible constraints, many valid loops
        // → not uniquely solvable → must not pass the audit.
        let p = Puzzle(cols: 2, rows: 2, inside: [[0,0]],
                       hide: [[0,0],[1,0],[0,1],[1,1]])
        let dp = DailyPuzzle(id: "y", tier: .sprout, puzzle: p)
        let reports = auditBundle(PuzzleBundle(byTier: [.sprout: [dp]]))
        #expect(reports[0].passed == false)
    }
}
