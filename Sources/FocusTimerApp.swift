import SwiftUI

@main
struct FocusTimerApp: App {
    var body: some Scene {
        MenuBarExtra {
            MainContentView()
        } label: {
            Text("🕰️")
        }
        .menuBarExtraStyle(.window)
    }
}
