import AppKit

/// Utilities for identifying the frontmost application precisely.
enum AppDetector {

    /// Returns the currently frontmost application, or `nil` if none.
    static func current() -> FrontmostApp? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }

        // Skip zombie apps (process is gone but NSWorkspace still references them
        // briefly after quit — leads to stale "frontmost = WeChat" reads).
        if app.isTerminated { return nil }

        let name = app.localizedName ?? "未知"
        let bundleID = app.bundleIdentifier ?? ""

        // Resolve icon lazily and cache by bundle id.
        let icon = NSWorkspace.shared.icon(forFile: app.bundleURL?.path ?? "")
        icon.size = NSSize(width: 32, height: 32)

        return FrontmostApp(name: name, bundleIdentifier: bundleID, icon: icon)
    }

    /// Returns `true` if the given bundle identifier belongs to this CheatSheet process itself.
    static func isSelf(_ bundleID: String) -> Bool {
        return bundleID == Bundle.main.bundleIdentifier
    }

    /// Whether the frontmost application is a Finder/system shell that should not be queried.
    static func isSystemShell(_ bundleID: String) -> Bool {
        // Don't try to show our own panel while our app is frontmost.
        return isSelf(bundleID)
    }
}
