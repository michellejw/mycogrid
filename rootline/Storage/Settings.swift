import Foundation
import SwiftUI
import ShroomKit

@MainActor
@Observable
final class Settings {
    private enum Keys {
        static let tutorialSeen = "rootline_tutorial_seen_v1"
        static let themeMode = "rootline_theme_mode_v1"
        static let archiveFloor = "rootline_archive_floor_v1"
    }

    var hasSeenTutorial: Bool {
        didSet { UserDefaults.standard.set(hasSeenTutorial, forKey: Keys.tutorialSeen) }
    }

    var themeMode: ThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: Keys.themeMode) }
    }

    init() {
        let d = UserDefaults.standard
        self.hasSeenTutorial = d.bool(forKey: Keys.tutorialSeen)
        self.themeMode = ThemeMode(rawValue: d.string(forKey: Keys.themeMode) ?? "") ?? .system
    }

    /// The archive's back-scroll floor: fixed once at first access to
    /// (firstOpen − 14 days), then never moved forward.
    var archiveFloor: Date {
        if let t = UserDefaults.standard.object(forKey: Keys.archiveFloor) as? Double {
            return Date(timeIntervalSince1970: t)
        }
        let floor = DailyService.archiveFloor(firstOpen: Date())
        UserDefaults.standard.set(floor.timeIntervalSince1970, forKey: Keys.archiveFloor)
        return floor
    }

    /// Cycle System → Light → Dark → System. The icon on the in-game button
    /// reflects the current mode, so each tap shows you what changes next.
    func cycleThemeMode() {
        switch themeMode {
        case .system:   themeMode = .forest
        case .forest:   themeMode = .twilight
        case .twilight: themeMode = .system
        }
    }
}
