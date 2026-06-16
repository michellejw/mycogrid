import SwiftUI
import ShroomKit

@MainActor
@Observable
final class TutorialFlow {
    var index: Int = 0
    var board: Board

    init() {
        let lesson = PuzzleData.lessons[0]
        self.board = Board(puzzle: lesson.puzzle, tier: nil, groveNumber: 1, allowHints: false)
    }

    var lesson: PuzzleData.Lesson {
        PuzzleData.lessons[index]
    }

    var isLast: Bool { index == PuzzleData.lessons.count - 1 }

    func next() {
        guard !isLast else { return }
        index += 1
        let l = PuzzleData.lessons[index]
        board = Board(puzzle: l.puzzle, tier: nil, groveNumber: index + 1, allowHints: false)
    }

    func skipToHome() {}
}

struct TutorialView: View {
    @Bindable var flow: TutorialFlow
    let settings: Settings
    let onFinish: () -> Void
    let onSkip: () -> Void

    @Environment(\.palette) private var palette
    @State private var showUnlock: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.bottom, 14)
            banner
                .padding(.bottom, 16)
            BoardView(board: flow.board, look: settings.look)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            unlockStrip
                .padding(.top, 16)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(palette.appBg.ignoresSafeArea())
        .onChange(of: flow.board.isSolved) { _, solved in
            if solved {
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    withAnimation(.easeInOut(duration: 0.3)) { showUnlock = true }
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: onSkip) {
                Text("Skip")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .padding(.horizontal, 14)
                    .frame(height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.pill)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer()
            Text("\(flow.index + 1) / \(PuzzleData.lessons.count)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1.3)
                .foregroundStyle(palette.sub)
            Spacer()
            // Spacer to balance the Skip button.
            Color.clear.frame(width: 60, height: 38)
        }
    }

    private var banner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(flow.lesson.eyebrow.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(1.3)
                .foregroundStyle(palette.sub)
            Text(flow.lesson.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.text)
            Text(flow.lesson.instruction)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(palette.sub)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.pill)
        )
    }

    @ViewBuilder
    private var unlockStrip: some View {
        if showUnlock {
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.accent)
                    Text("Unlocked: \"\(flow.lesson.unlock)\"")
                        .font(.system(size: 13.5, design: .rounded))
                        .foregroundStyle(palette.text)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(palette.tierSelBg)
                )
                Button(action: advance) {
                    Text(flow.isLast ? "Start playing" : "Next lesson")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.accentText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(palette.accent)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .transition(.opacity)
        }
    }

    private func advance() {
        if flow.isLast {
            onFinish()
        } else {
            flow.next()
            withAnimation(.easeInOut(duration: 0.25)) { showUnlock = false }
        }
    }
}
