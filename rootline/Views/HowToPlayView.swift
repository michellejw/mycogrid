import SwiftUI
import ShroomKit

struct HowToPlayView: View {
    let onBack: () -> Void
    let onStartTutorial: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 18)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    rule(
                        title: "Draw one closed loop",
                        body: "Tap the edge between two dots to add a thread. Your finished loop is one continuous ring — no branches, no dead ends."
                    )
                    rule(
                        title: "Numbers are spore counts",
                        body: "A clue says exactly how many of its four edges must carry thread. A 0 means none of them do."
                    )
                    rule(
                        title: "Mark dead roots",
                        body: "Switch the mode toggle to “Mark dead” to cross out an edge you know is empty. It's just a note to yourself — it doesn't count as thread."
                    )
                    rule(
                        title: "Win quietly",
                        body: "When the loop closes and every clue is satisfied, the threads glow and a card slides up. You can replay or pick the next puzzle."
                    )
                    rule(
                        title: "Hints are gentle",
                        body: "Tap “?” for an escalating hint — a region first, then a nudge, then one correct edge. You have three per puzzle, never more."
                    )
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
            Spacer(minLength: 0)
            Button(action: onStartTutorial) {
                Text("Walk me through it")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.accentText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(palette.accent)
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.bottom, 24)
        }
        .background(palette.appBg.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12) {
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
            Text("How to play")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.text)
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private func rule(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.text)
            Text(body)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(palette.sub)
                .lineSpacing(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.pill)
        )
    }
}
