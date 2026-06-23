// scripts/MycogridSolver/Tests/MycogridSolverTests/CompletionStoreTests.swift
import Testing
import Foundation
@testable import MycogridSolver

@MainActor @Suite struct CompletionStoreTests {
    func freshStore() -> CompletionStore {
        let suite = "test-completions"
        let d = UserDefaults(suiteName: suite)!
        d.removePersistentDomain(forName: suite)
        return CompletionStore(defaults: d)
    }

    @Test func recordsAndReportsCleared() {
        let s = freshStore()
        #expect(s.isCleared("a") == false)
        _ = s.record(id: "a", tier: .sprout, seconds: 90)
        #expect(s.isCleared("a"))
        #expect(s.totalCleared == 1)
        #expect(s.clearedCount(for: .sprout) == 1)
        #expect(s.bestSeconds(for: .sprout) == 90)
    }

    @Test func firstClearIsNotAWhisper() {
        let s = freshStore()
        #expect(s.record(id: "a", tier: .sprout, seconds: 90) == false)
    }

    @Test func fasterReclearOfTierWhispers() {
        let s = freshStore()
        _ = s.record(id: "a", tier: .sprout, seconds: 90)
        #expect(s.record(id: "b", tier: .sprout, seconds: 80) == true)   // beat 90
        #expect(s.bestSeconds(for: .sprout) == 80)
    }

    @Test func slowerReclearDoesNotWhisperOrRegressBest() {
        let s = freshStore()
        _ = s.record(id: "a", tier: .sprout, seconds: 80)
        #expect(s.record(id: "a", tier: .sprout, seconds: 95) == false)
        #expect(s.bestSeconds(for: .sprout) == 80)   // keeps fastest
        #expect(s.totalCleared == 1)                 // same id, still one
    }

    @Test func perTierIsolationAndTotals() {
        let s = freshStore()
        _ = s.record(id: "a", tier: .sprout, seconds: 90)
        _ = s.record(id: "b", tier: .oldGrowth, seconds: 300)
        #expect(s.totalCleared == 2)
        #expect(s.clearedCount(for: .sprout) == 1)
        #expect(s.clearedCount(for: .mycelium) == 0)
        #expect(s.bestSeconds(for: .mycelium) == nil)
    }

    @Test func persistsAcrossInstances() {
        let suite = "test-completions-persist"
        let d = UserDefaults(suiteName: suite)!
        d.removePersistentDomain(forName: suite)
        let a = CompletionStore(defaults: d)
        _ = a.record(id: "a", tier: .ancient, seconds: 120)
        let b = CompletionStore(defaults: d)
        #expect(b.isCleared("a"))
        #expect(b.bestSeconds(for: .ancient) == 120)
    }

    @Test func clearAllResets() {
        let s = freshStore()
        _ = s.record(id: "a", tier: .sprout, seconds: 90)
        s.clearAll()
        #expect(s.totalCleared == 0)
        #expect(s.hasAnyStats == false)
    }
}
