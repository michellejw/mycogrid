import SwiftUI
import ShroomKit

struct HomeView: View {
    let tier: Tier
    let onPickDifficulty: () -> Void
    let onPlay: () -> Void
    let onHowToPlay: () -> Void
    let onSettings: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.sub)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.pill)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
            VStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(palette.pill)
                    .frame(width: 92, height: 92)
                    .overlay(MyceliumIcon().padding(16))
                Text("Rootline")
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.text)
                Text("A cozy loop puzzle for mushroom foragers.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 230)
            }
            Spacer(minLength: 0)
            VStack(spacing: 11) {
                difficultyCard
                primaryButton("Play", action: onPlay)
                secondaryButton("How to play", action: onHowToPlay)
            }
            Spacer(minLength: 24)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.appBg.ignoresSafeArea())
    }

    private var difficultyCard: some View {
        Button(action: onPickDifficulty) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("DIFFICULTY")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.3)
                        .foregroundStyle(palette.sub)
                    Text(tier.label)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.text)
                    Text(tier.meta)
                        .font(.system(size: 12.5, design: .rounded))
                        .foregroundStyle(palette.sub)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.sub)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(palette.pill)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(palette.accentText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(palette.accent)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(palette.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(palette.pill)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
