
import SwiftUI

@main
struct TaskTrekApp: App {
    @StateObject private var store = TodoStore()
    @State private var prefs: AppPrefs = .load()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(prefs.accent.color)
                .modifier(EnvironmentValuesModifier(prefs: $prefs))
        }
    }
}
