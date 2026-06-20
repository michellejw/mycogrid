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
            SettingsSection("Theme") {
                HStack(spacing: 8) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        SelectionChip(mode.label, isSelected:settings.themeMode == mode) {
                            settings.themeMode = mode
                        }
                    }
                }
                Text("System follows your phone's Light/Dark setting.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(palette.sub)
                    .padding(.top, 2)
            }
            SettingsSection("Thread look") {
                lookPreview
                HStack(spacing: 8) {
                    ForEach(LookVariant.allCases, id: \.self) { v in
                        SelectionChip(v.label, isSelected:settings.look == v) {
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
            SettingsSection("Timer") {
                Toggle(isOn: $settings.showTimer) {
                    Text("Show on play screen")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(palette.text)
                }
                .tint(palette.accent)
            }
            SettingsSection("Tutorial") {
                SettingsRow(icon: "graduationcap", label: "Replay tutorial lessons") { onTutorial() }
            }
#if DEBUG
            SettingsSection("Debug") {
                SettingsRow(icon: "square.grid.3x3.square", label: "Puzzle editor") { onPuzzleEditor?() }
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

}
