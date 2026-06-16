import Foundation

enum Tier: String, CaseIterable, Identifiable, Codable, Sendable {
    case sprout
    case mycelium
    case ancient
    case oldGrowth

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sprout:     return "Sprout"
        case .mycelium:   return "Mycelium"
        case .ancient:    return "Ancient"
        case .oldGrowth:  return "Old Growth"
        }
    }

    var cols: Int {
        switch self {
        case .sprout:    return 4
        case .mycelium:  return 5
        case .ancient:   return 6
        case .oldGrowth: return 7
        }
    }

    var rows: Int {
        switch self {
        case .sprout:    return 6
        case .mycelium:  return 7
        case .ancient:   return 9
        case .oldGrowth: return 10
        }
    }

    var meta: String {
        switch self {
        case .sprout:    return "4 × 6 · most clues shown"
        case .mycelium:  return "5 × 7 · medium clues"
        case .ancient:   return "6 × 9 · sparse clues"
        case .oldGrowth: return "7 × 10 · minimal clues"
        }
    }

    var shortMeta: String { "\(cols)×\(rows)" }

    static let `default`: Tier = .mycelium
}
