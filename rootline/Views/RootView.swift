import SwiftUI
import ShroomKit

enum Screen {
    case launching
    case welcome
    case home
    case difficulty
    case howToPlay
    case play
    case tutorial
}

@MainActor
@Observable
final class AppState {
    var screen: Screen = .launching
    let settings: Settings = Settings()

    var activeBoard: Board?
    var tutorial: TutorialFlow?

    private var currentPuzzleIndex: Int = 0

    /// Called once when the launch loader finishes its first beat.
    func finishLaunch() {
        if !settings.hasSeenTutorial {
            screen = .welcome
        } else {
            screen = .home
        }
    }

    func skipWelcome() {
        settings.hasSeenTutorial = true
        screen = .home
    }

    func startGame(tier: Tier) {
        settings.tier = tier
        currentPuzzleIndex = 0
        let puzzles = PuzzleData.puzzles(for: tier)
        let puzzle = puzzles[currentPuzzleIndex]
        activeBoard = Board(
            puzzle: puzzle,
            tier: tier,
            groveNumber: currentPuzzleIndex + 1
        )
        screen = .play
    }

    func nextPuzzle() {
        guard let tier = activeBoard?.tier else { return }
        let puzzles = PuzzleData.puzzles(for: tier)
        currentPuzzleIndex = (currentPuzzleIndex + 1) % puzzles.count
        activeBoard = Board(
            puzzle: puzzles[currentPuzzleIndex],
            tier: tier,
            groveNumber: currentPuzzleIndex + 1
        )
    }

    func goHome() {
        screen = .home
    }

    func openDifficulty() {
        screen = .difficulty
    }

    func openHowToPlay() {
        screen = .howToPlay
    }

    func startTutorial() {
        tutorial = TutorialFlow()
        screen = .tutorial
    }

    func finishTutorial() {
        settings.hasSeenTutorial = true
        tutorial = nil
        screen = .home
    }
}

struct RootView: View {
    @State private var appState = AppState()
    @State private var showSettings: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = Palette.palette(for: colorScheme)
        ZStack {
            palette.appBg.ignoresSafeArea()
            content
        }
        .environment(\.palette, palette)
        .preferredColorScheme(appState.settings.themeMode.preferredColorScheme)
        .animation(.easeInOut(duration: 0.22), value: appState.screen)
        .sheet(isPresented: $showSettings) {
            SettingsSheet(
                settings: appState.settings,
                onTutorial: {
                    showSettings = false
                    appState.startTutorial()
                },
                onClose: { showSettings = false }
            )
            .environment(\.palette, palette)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appState.screen {
        case .launching:
            LoadingView(message: "Loading") {
                MyceliumIcon()
            }
            .transition(.opacity)
            .task {
                try? await Task.sleep(for: .milliseconds(700))
                appState.finishLaunch()
            }
        case .welcome:
            WelcomeScaffold(
                title: "Welcome to Rootline",
                tagline: "A cozy loop puzzle for mushroom foragers. Want a quick tour before you dig in?",
                primaryLabel: "Show me how to play",
                secondaryLabel: "Jump right in",
                onPrimary: { appState.startTutorial() },
                onSecondary: { appState.skipWelcome() }
            ) {
                MyceliumIcon()
            }
            .transition(.opacity)
        case .home:
            HomeView(
                tier: appState.settings.tier,
                onPickDifficulty: { appState.openDifficulty() },
                onPlay: { appState.startGame(tier: appState.settings.tier) },
                onHowToPlay: { appState.openHowToPlay() },
                onSettings: { showSettings = true }
            )
            .transition(.opacity)
        case .difficulty:
            DifficultyView(
                selected: appState.settings.tier,
                onBack: { appState.goHome() },
                onPick: { tier in appState.startGame(tier: tier) }
            )
            .transition(.opacity)
        case .howToPlay:
            HowToPlayView(
                onBack: { appState.goHome() },
                onStartTutorial: { appState.startTutorial() }
            )
            .transition(.opacity)
        case .play:
            if let board = appState.activeBoard {
                PlayView(
                    board: board,
                    settings: appState.settings,
                    onBack: { appState.openDifficulty() },
                    onNext: { appState.nextPuzzle() },
                    onMenu: { appState.goHome() }
                )
                .transition(.opacity)
            }
        case .tutorial:
            if let flow = appState.tutorial {
                TutorialView(
                    flow: flow,
                    settings: appState.settings,
                    onFinish: { appState.finishTutorial() },
                    onSkip: { appState.finishTutorial() }
                )
                .transition(.opacity)
            }
        }
    }
}
