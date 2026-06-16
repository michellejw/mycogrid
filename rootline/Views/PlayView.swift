import SwiftUI
import ShroomKit

struct PlayView: View {
    @Bindable var board: Board
    let settings: Settings
    let onBack: () -> Void
    let onNext: () -> Void
    let onMenu: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 6)
            statsRow
                .padding(.top, 14)
                .padding(.bottom, 10)
            BoardView(board: board, look: settings.look)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 8)
            if !board.isSolved {
                modeToggle
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .transition(.opacity)
            } else {
                Color.clear.frame(height: 96)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 4)
        .background(palette.appBg.ignoresSafeArea())
        .overlay(alignment: .bottom) {
            if board.isSolved {
                WinCard(board: board, onNext: onNext, onMenu: onMenu)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: board.isSolved)
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: board.tapTick)
        .sensoryFeedback(.success, trigger: board.solveTick)
        .task(id: ObjectIdentifier(board)) {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                board.tick()
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.sub)
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.pill)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Spacer()
            VStack(spacing: 1) {
                Text((board.tier?.label ?? "Lesson").uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.3)
                    .foregroundStyle(palette.sub)
                Text("Grove #\(board.groveNumber)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.text)
            }
            Spacer()
            Button(action: { board.nextHint() }) {
                Image(systemName: "questionmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(board.allowHints && board.hintsRemaining > 0
                                     ? palette.sub
                                     : palette.sub.opacity(0.35))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(palette.pill)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!board.allowHints || board.hintsRemaining == 0 || board.isSolved)
        }
    }

    // MARK: Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            Spacer()
            if settings.showTimer {
                statPill(systemName: "clock", text: board.elapsedSeconds.asTimerString)
            }
            if board.allowHints {
                hintsPill
            }
            if let msg = board.hintMessage {
                Text(msg)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .transition(.opacity)
            }
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: board.hintMessage)
    }

    private func statPill(systemName: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.sub)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.text)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.pill)
        )
    }

    private var hintsPill: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(palette.accent)
                    .frame(width: 8, height: 8)
            }
            Text("\(board.hintsRemaining) hints")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.text)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.pill)
        )
    }

    // MARK: Mode toggle

    private var modeToggle: some View {
        HStack(spacing: 6) {
            segment(title: "Draw thread",
                    icon: { AnyView(threadGlyph) },
                    isActive: board.mode == .draw,
                    action: { board.mode = .draw })
            segment(title: "Mark dead",
                    icon: { AnyView(
                        Text("✕")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    ) },
                    isActive: board.mode == .mark,
                    action: { board.mode = .mark })
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
                    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
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
}

extension Int {
    var asTimerString: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%d:%02d", m, s)
    }
}
