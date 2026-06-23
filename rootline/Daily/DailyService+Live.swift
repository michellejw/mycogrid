import Foundation

extension DailyService {
    /// Loads `puzzles.json` from the app bundle. Asserts in DEBUG on failure
    /// (a packaging defect); returns nil in release for a graceful surface.
    static func live(calendar: Calendar = .autoupdatingCurrent) -> DailyService? {
        guard let url = Bundle.main.url(forResource: "puzzles", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            assertionFailure("puzzles.json missing from app bundle")
            return nil
        }
        do {
            return DailyService(bundle: try PuzzleBundle(data: data), calendar: calendar)
        } catch {
            assertionFailure("puzzles.json failed to decode: \(error)")
            return nil
        }
    }
}
