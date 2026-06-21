// RegionTests.swift
import XCTest
@testable import MycogridSolver

final class RegionTests: XCTestCase {
    private func cells(_ pairs: [[Int]]) -> Set<Cell> {
        Set(pairs.map { Cell(c: $0[0], r: $0[1]) })
    }

    func test_solidRectangle_isSimplyConnected() {
        // 2x2 block inside a 3x3 grid.
        let region = cells([[0,0],[1,0],[0,1],[1,1]])
        XCTAssertTrue(isSimplyConnected(region, cols: 3, rows: 3))
    }

    func test_regionWithHole_isRejected() {
        // Ring of 8 cells around an empty center in a 3x3 grid — center (1,1) is a hole.
        let ring = cells([[0,0],[1,0],[2,0],[0,1],[2,1],[0,2],[1,2],[2,2]])
        XCTAssertFalse(isSimplyConnected(ring, cols: 3, rows: 3))
    }

    func test_disconnectedRegion_isRejected() {
        // Two separate cells in a 3x3 grid.
        let region = cells([[0,0],[2,2]])
        XCTAssertFalse(isSimplyConnected(region, cols: 3, rows: 3))
    }

    func test_emptyRegion_isRejected() {
        XCTAssertFalse(isSimplyConnected([], cols: 3, rows: 3))
    }

    func test_wholeGrid_isRejected() {
        let all = cells([[0,0],[1,0],[0,1],[1,1]])
        XCTAssertFalse(isSimplyConnected(all, cols: 2, rows: 2))
    }
}
