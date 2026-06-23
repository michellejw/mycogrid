import Foundation

/// One cleared puzzle, keyed externally by its stable id.
struct Completion: Codable, Equatable, Sendable {
    let tier: Tier
    var bestSeconds: Int
}

/// Single source of truth for cleared status and derived stats. Keyed by the
/// puzzle's stable content id so history survives pool growth/reordering.
@MainActor
@Observable
final class CompletionStore {
    private static let key = "rootline_completions_v1"
    private let defaults: UserDefaults

    private(set) var byID: [String: Completion] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func isCleared(_ id: String) -> Bool { byID[id] != nil }
    func isCleared(_ p: DailyPuzzle) -> Bool { isCleared(p.id) }

    /// Record a clear; keep the fastest time on re-clear. Returns true only when
    /// this beat a pre-existing per-tier best (the calm "your fastest yet"
    /// whisper). A first clear in a tier returns false.
    @discardableResult
    func record(id: String, tier: Tier, seconds: Int) -> Bool {
        let priorTierBest = bestSeconds(for: tier)
        if var existing = byID[id] {
            if seconds < existing.bestSeconds {
                existing.bestSeconds = seconds
                byID[id] = existing
            }
        } else {
            byID[id] = Completion(tier: tier, bestSeconds: seconds)
        }
        persist()
        if let prior = priorTierBest { return seconds < prior }
        return false
    }

    var totalCleared: Int { byID.count }
    func clearedCount(for tier: Tier) -> Int { byID.values.filter { $0.tier == tier }.count }
    func bestSeconds(for tier: Tier) -> Int? {
        byID.values.filter { $0.tier == tier }.map(\.bestSeconds).min()
    }
    var hasAnyStats: Bool { !byID.isEmpty }

    func clearAll() {
        byID = [:]
        persist()
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([String: Completion].self, from: data) else { return }
        byID = decoded
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(byID) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
