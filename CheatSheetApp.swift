import AppKit

@main
struct CheatSheetApp {
    static func main() {
        let app = NSApplication.shared
        // Accessory: lives in the menu bar, no Dock icon.
        app.setActivationPolicy(.accessory)

        let delegate = AppDelegate()
        app.delegate = delegate

        app.run()
    }
}
