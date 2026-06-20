import SwiftUI
import ShroomKit

struct SettingsSheet: View {
    @Bindable var settings: Settings
    let onTutorial: () -> Void
    let onClose: () -> Void
    var onPuzzleEditor: (() -> Void)? = nil

    @Environment(\.palette) private var palette

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Settings")
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(palette.text)
                    Spacer()
                }
            section(title: "Theme") {
                HStack(spacing: 8) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        chip(label: mode.label, isActive: settings.themeMode == mode) {
                            settings.themeMode = mode
                        }
                    }
                }
                Text("System follows your phone's Light/Dark setting.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .padding(.top, 2)
            }
            section(title: "Thread look") {
                lookPreview
                HStack(spacing: 8) {
                    ForEach(LookVariant.allCases, id: \.self) { v in
                        chip(label: v.label, isActive: settings.look == v) {
                            settings.look = v
                        }
                    }
                }
                Text(settings.look == .glow
                     ? "Luminous thread with a soft halo."
                     : "Flat, high-contrast thread — no glow.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .padding(.top, 2)
            }
            section(title: "Timer") {
                Toggle(isOn: $settings.showTimer) {
                    Text("Show on play screen")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(palette.text)
                }
                .tint(palette.accent)
            }
            section(title: "Tutorial") {
                Button(action: { onTutorial() }) {
                    HStack {
                        Image(systemName: "graduationcap")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.accent)
                        Text("Replay tutorial lessons")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.sub)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.tierBg)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
#if DEBUG
            section(title: "Debug") {
                Button(action: { onPuzzleEditor?() }) {
                    HStack {
                        Image(systemName: "square.grid.3x3.square")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.accent)
                        Text("Puzzle editor")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(palette.sub)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.tierBg)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
#endif
            HStack {
                Spacer()
                Text("Part of Shroom Games")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(palette.sub)
                Spacer()
            }
            .padding(.top, 14)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(palette.appBg.ignoresSafeArea())
    }

    private var lookPreview: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.boardBg)
                .frame(width: 160, height: 104)
                .overlay(
                    MyceliumIcon(glow: settings.look == .glow)
                        .frame(width: 72, height: 72)
                )
            Spacer()
        }
        .animation(.easeInOut(duration: 0.25), value: settings.look)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            EyebrowLabel(title)
            content()
        }
    }

    private func chip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(isActive ? palette.accentText : palette.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isActive ? palette.accent : palette.pill)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
