import Foundation
import AppKit

/// A single keyboard shortcut entry.
struct Shortcut: Identifiable, Hashable {
    let id: UUID
    let keys: String          // Display text, e.g. "⌘S", "⇧⌘P", "⌥⌘⎋"
    let title: String         // Human-readable action, e.g. "Save"

    init(keys: String, title: String) {
        self.id = UUID()
        self.keys = keys
        self.title = title
    }
}

/// A grouped set of shortcuts that share a functional purpose.
struct ShortcutCategory: Identifiable {
    let id: UUID
    let name: String          // e.g. "File", "Edit", "View"
    let symbol: String        // SF Symbol name
    let shortcuts: [Shortcut]

    init(name: String, symbol: String, shortcuts: [Shortcut]) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.shortcuts = shortcuts
    }
}

/// Describes the frontmost application at the moment the panel is shown.
struct FrontmostApp: Equatable {
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?

    static let unknown = FrontmostApp(
        name: "未知应用",
        bundleIdentifier: "",
        icon: nil
    )

    static func == (lhs: FrontmostApp, rhs: FrontmostApp) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
            && lhs.name == rhs.name
    }
}
