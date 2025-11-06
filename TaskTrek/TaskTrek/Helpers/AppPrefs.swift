
import SwiftUI

struct AppPrefs: Codable, Equatable {
    var hapticsEnabled: Bool = true
    var accent: Accent = .blue

    enum Accent: String, CaseIterable, Codable, Identifiable {
        case blue, green, orange, pink, purple, red, teal
        var id: String { rawValue }
        var color: Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .pink: return .pink
            case .purple: return .purple
            case .red: return .red
            case .teal: return .teal
            }
        }
        var label: String { rawValue.capitalized }
    }
}

struct PrefsStorageKey { static let key = "app_prefs_v1" }

extension AppPrefs {
    static func load() -> AppPrefs {
        if let data = UserDefaults.standard.data(forKey: PrefsStorageKey.key),
           let prefs = try? JSONDecoder().decode(AppPrefs.self, from: data) { return prefs }
        return AppPrefs()
    }

    static func save(_ prefs: AppPrefs) {
        if let data = try? JSONEncoder().encode(prefs) {
            UserDefaults.standard.set(data, forKey: PrefsStorageKey.key)
        }
    }
}

struct EnvironmentValuesModifier: ViewModifier {
    @Binding var prefs: AppPrefs
    func body(content: Content) -> some View { content.environment(\._appPrefs, $prefs) }
}

struct AppPrefsKey: EnvironmentKey {
    static let defaultValue: Binding<AppPrefs> = .constant(.init())
}

extension EnvironmentValues {
    var _appPrefs: Binding<AppPrefs> {
        get { self[AppPrefsKey.self] }
        set { self[AppPrefsKey.self] = newValue }
    }
}
