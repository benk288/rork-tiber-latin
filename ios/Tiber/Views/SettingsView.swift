import SwiftUI

/// Accessibility-first settings sheet.
struct SettingsView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var app = app
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        CiceroAvatar(size: 52)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.progress.playerName)
                                .font(app.font(18, weight: .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Pupil of Cicero's Academy")
                                .font(app.font(13))
                                .foregroundStyle(Theme.brown)
                        }
                    }
                    .listRowBackground(Theme.parchment)
                }

                Section("Reading") {
                    Toggle(isOn: $app.progress.readableFont) {
                        settingLabel(symbol: "textformat", title: "Easy-read font", detail: "Rounded letters that are easier to tell apart")
                    }
                    Toggle(isOn: $app.progress.colorBlindMode) {
                        settingLabel(symbol: "eye.fill", title: "Color-blind mode", detail: "Blue and amber feedback instead of green and red")
                    }
                }
                .listRowBackground(Theme.cream)

                Section("Playing") {
                    VStack(alignment: .leading, spacing: 8) {
                        settingLabel(symbol: "speedometer", title: "Game speed", detail: speedLabel)
                        Picker("Game speed", selection: $app.progress.gameSpeed) {
                            Text("Relaxed").tag(0.7)
                            Text("Normal").tag(1.0)
                            Text("Swift").tag(1.4)
                        }
                        .pickerStyle(.segmented)
                    }
                    Toggle(isOn: $app.progress.largeTouchTargets) {
                        settingLabel(symbol: "hand.tap.fill", title: "Larger touch targets", detail: "Bigger buttons for smaller hands")
                    }
                }
                .listRowBackground(Theme.cream)

                Section("Sound") {
                    Toggle(isOn: $app.progress.audioHints) {
                        settingLabel(symbol: "speaker.wave.3.fill", title: "Read aloud", detail: "Cicero speaks his messages and hints out loud")
                    }
                    Button {
                        SpeechService.shared.speak("Salve! Ego sum Cicero.")
                    } label: {
                        settingLabel(symbol: "play.circle.fill", title: "Test pronunciation", detail: "Hear a sample Latin phrase")
                    }
                }
                .listRowBackground(Theme.cream)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.creamGradient)
            .tint(Theme.orange)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(app.font(16, weight: .bold))
                        .foregroundStyle(Theme.terracotta)
                }
            }
        }
    }

    private var speedLabel: String {
        switch app.progress.gameSpeed {
        case ..<0.9: return "Relaxed - more time for every puzzle"
        case ..<1.2: return "Normal pace"
        default: return "Swift - for seasoned pupils"
        }
    }

    private func settingLabel(symbol: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16))
                .foregroundStyle(Theme.terracotta)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Theme.parchment))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(app.font(15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(app.font(12))
                    .foregroundStyle(Theme.brown.opacity(0.8))
            }
        }
    }
}
