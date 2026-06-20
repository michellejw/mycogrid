import XCTest
@testable import MycogridSolver

final class SolverTests: XCTestCase {
    func test_1x1_clue4_isUniqueWithFourEdges() {
        let result = solve(PuzzleClues(cols: 1, rows: 1, clues: [Cell(c: 0, r: 0): 4]))
        XCTAssertEqual(result.verdict, .unique)
        XCTAssertEqual(result.solution?.count, 4)
        XCTAssertNil(result.witness)
        XCTAssertEqual(result.trace.guesses, 0) // solved by pure deduction
    }

    func test_noClues_isMultiple() {
        let result = solve(PuzzleClues(cols: 2, rows: 2, clues: [:]))
        XCTAssertEqual(result.verdict, .multiple)
        XCTAssertNotNil(result.solution)
        XCTAssertNotNil(result.witness)
        XCTAssertNotEqual(result.solution, result.witness)
    }

    func test_contradictoryClue_isNone() {
        let result = solve(PuzzleClues(cols: 1, rows: 1, clues: [Cell(c: 0, r: 0): 3]))
        XCTAssertEqual(result.verdict, .none)
        XCTAssertNil(result.solution)
    }

    func test_twoAdjacentCells_clued_isSingleLoop() {
        // A 2x1 board where both cells are inside: the boundary is one 6-edge loop.
        let result = solve(PuzzleClues(cols: 2, rows: 1,
            clues: [Cell(c: 0, r: 0): 3, Cell(c: 1, r: 0): 3]))
        XCTAssertEqual(result.verdict, .unique)
        XCTAssertEqual(result.solution?.count, 6)
    }
}
