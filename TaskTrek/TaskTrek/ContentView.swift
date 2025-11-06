
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView().environmentObject(TodoStore())
    }
}

#Preview { ContentView() }
