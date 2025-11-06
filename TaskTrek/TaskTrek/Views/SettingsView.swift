
import SwiftUI

struct SettingsView: View {
    @Environment(\._appPrefs) private var prefs

    var body: some View {
        Form {
            Section("Haptics") {
                Toggle("Enable haptics", isOn: prefs.hapticsEnabled)
            }
            Section("Accent Color") {
                Picker("Accent", selection: prefs.accent) {
                    ForEach(AppPrefs.Accent.allCases) { acc in
                        HStack {
                            Circle().fill(acc.color).frame(width: 12, height: 12)
                            Text(acc.label)
                        }.tag(acc)
                    }
                }
            }
            Section(footer: Text("These settings save automatically.")) { EmptyView() }
        }
        .navigationTitle("Settings")
    }
}
