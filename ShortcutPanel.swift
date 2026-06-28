import AppKit
import SwiftUI

/// A borderless, non-activating floating panel used to display shortcut hints.
/// Non-activating means it never steals key focus from the frontmost app,
/// so any keystroke continues to flow to the user's actual application.
final class ShortcutPanel: NSPanel {

    init(contentSize: NSSize = NSSize(width: 480, height: 540)) {
        super.init(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.borderless, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )

        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isMovableByWindowBackground = true
        self.hidesOnDeactivate = false
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        // Follow system appearance; SwiftUI uses adaptive colors.
        self.appearance = nil
    }

    // Never become key/main so that frontmost app keeps focus.
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    /// Replaces the SwiftUI content hosted by this panel.
    func setContent<Content: View>(_ view: Content) {
        let host = NSHostingView(rootView: AnyView(view))
        host.autoresizingMask = [.width, .height]
        host.translatesAutoresizingMaskIntoConstraints = true
        self.contentView = host
        // Make sure the host fills the content rect assigned by the panel.
        host.frame = self.contentView?.bounds ?? .zero
    }

    /// Positions the panel centered above the current cursor location, clamped
    /// to the visible frame of the screen that contains the cursor.
    func positionNearCursor() {
        guard let screen = screenContainingCursor() else {
            centerOnMainScreen()
            return
        }

        let mouse = NSEvent.mouseLocation
        let size = self.frame.size
        let visible = screen.visibleFrame

        // Default: directly above the cursor.
        var origin = NSPoint(
            x: mouse.x - size.width / 2,
            y: mouse.y - size.height - 28
        )

        // Flip below the cursor if there isn't room above.
        if origin.y < visible.minY + 8 {
            origin.y = mouse.y + 28
        }

        // Clamp horizontally.
        origin.x = max(visible.minX + 8, min(origin.x, visible.maxX - size.width - 8))
        // Clamp vertically (in case flipped below also exceeds maxY).
        origin.y = max(visible.minY + 8, min(origin.y, visible.maxY - size.height - 8))

        self.setFrameOrigin(origin)
    }

    private func centerOnMainScreen() {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let size = self.frame.size
        let origin = NSPoint(
            x: visible.midX - size.width / 2,
            y: visible.midY - size.height / 2
        )
        self.setFrameOrigin(origin)
    }

    private func screenContainingCursor() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { $0.frame.contains(mouse) }) ?? NSScreen.main
    }
}
