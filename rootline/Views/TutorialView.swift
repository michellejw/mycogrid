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
}

struct TutorialView: View {
    @Bindable var flow: TutorialFlow
    let settings: Settings
    let onFinish: () -> Void
    let onSkip: () -> Void

    @Environment(\.palette) private var palette
    @State private var showUnlock: Bool = false
    @State private var errorMessage: String? = nil
    @State private var stuckHint: String? = nil

    private let coachingHeight: CGFloat = 56

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.bottom, 10)
            instructionPill
                .padding(.bottom, 8)
            coachingSlot
                .padding(.bottom, 6)
            BoardView(board: flow.board, look: settings.look)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if !flow.board.isSolved {
                modeToggle
                    .padding(.top, 14)
                    .transition(.opacity)
            }
            unlockStrip
                .padding(.top, 16)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(palette.appBg.ignoresSafeArea())
        .onChange(of: flow.index) { _, _ in
            showUnlock = false
            errorMessage = nil
            stuckHint = nil
        }
        .onChange(of: flow.board.tapTick) { _, _ in
            stuckHint = nil
            evaluateClues()
        }
        .onChange(of: flow.board.isSolved) { _, solved in
            if solved {
                stuckHint = nil
                errorMessage = nil
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    withAnimation(.easeInOut(duration: 0.3)) { showUnlock = true }
                }
            }
        }
        .task(id: "\(flow.index)-\(flow.board.tapTick)") {
            try? await Task.sleep(for: .seconds(45))
            if !Task.isCancelled, !flow.board.isSolved {
                stuckHint = flow.lesson.stuckHint
            }
        }
    }

    // MARK: Top bar (Skip only — no page counter)

    private var topBar: some View {
        HStack {
            Button(action: onSkip) {
                Text("Skip all")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.sub)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.pill)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer()
            Button(action: skipLesson) {
                HStack(spacing: 4) {
                    Text(flow.isLast ? "Finish" : "Skip lesson")
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                    Image(systemName: "chevron.right")
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                }
                .foregroundStyle(palette.sub)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func skipLesson() {
        if flow.isLast {
            onFinish()
        } else {
            flow.next()
        }
    }

    // MARK: Instruction pill

    private var instructionPill: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(flow.lesson.title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.text)
                Text(flow.lesson.instruction)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.pill)
        )
    }

    // MARK: Coaching slot (fixed height, opacity-toggled so layout never jumps)

    private var coachingSlot: some View {
        let msg = errorMessage ?? stuckHint
        let isError = errorMessage != nil
        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "lightbulb.fill")
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(isError ? palette.warn : palette.accent)
            Text(msg ?? " ")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(palette.text)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: coachingHeight)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(msg == nil ? Color.clear : palette.tierSelBg)
        )
        .opacity(msg == nil ? 0 : 1)
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
        .animation(.easeInOut(duration: 0.2), value: stuckHint)
    }

    // MARK: Draw / Mark mode toggle (mirrors PlayView)

    private var modeToggle: some View {
        HStack(spacing: 6) {
            segment(title: "Draw thread",
                    icon: { AnyView(threadGlyph) },
                    isActive: flow.board.mode == .draw,
                    action: { flow.board.mode = .draw })
            segment(title: "Mark dead",
                    icon: { AnyView(
                        Text("✕")
                            .font(.system(.footnote, design: .rounded).weight(.semibold))
                    ) },
                    isActive: flow.board.mode == .mark,
                    action: { flow.board.mode = .mark })
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.pill)
        )
    }

    private var threadGlyph: some View {
        Capsule()
            .fill(Color.primary)
            .frame(width: 13, height: 3)
    }

    private func segment(title: String, icon: () -> AnyView, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                icon()
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.vertical, 4)
            .foregroundStyle(isActive ? palette.accentText : palette.sub)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? palette.accent : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }

    // MARK: Over-fill detection

    private func evaluateClues() {
        let model = flow.board.model
        let p = model.puzzle
        var hasUnderFilled = false
        for r in 0..<p.rows {
            for c in 0..<p.cols {
                let cell = Cell(c: c, r: r)
                guard let target = model.clues[cell],
                      !p.hideClues.contains(cell) else { continue }
                let count = model.count(cell: cell, in: flow.board.activeEdges)
                if count > target {
                    let msg = target == 0
                        ? "That cell wants no thread — switch to Mark dead and X out its edges."
                        : "That cell only takes \(target) thread\(target == 1 ? "" : "s")."
                    errorMessage = msg
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        if errorMessage == msg { errorMessage = nil }
                    }
                    return
                }
                if count < target { hasUnderFilled = true }
            }
        }
        // No over-fills. If the loop closes but a visible clue still wants more
        // thread, the player drew a *different* loop from the intended one and
        // probably thinks they're done. Nudge them at the unsatisfied clue.
        if hasUnderFilled, !flow.board.isSolved,
           model.isClosedLoop(active: flow.board.activeEdges) {
            errorMessage = "Your loop closes, but a clue still wants more thread. Look for the number that isn't green."
            return
        }
        errorMessage = nil
    }

    // MARK: Unlock strip (post-solve)

    @ViewBuilder
    private var unlockStrip: some View {
        if showUnlock {
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(.footnote, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.accent)
                    Text("Unlocked: \"\(flow.lesson.unlock)\"")
                        .font(.system(.footnote, design: .rounded))
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
                Button(flow.isLast ? "Start playing" : "Next lesson", action: advance)
                    .buttonStyle(.shroomPrimary)
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
