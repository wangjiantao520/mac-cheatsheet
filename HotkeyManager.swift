import AppKit

/// Listens for Command-key state changes and any subsequent key presses
/// across the entire system. Global monitors can only OBSERVE events,
/// not consume them — which is exactly what we want so that the frontmost
/// application still receives the keystroke.
///
/// Long-press semantics: `onCommandDown` only fires after the Command key
/// has been held continuously for `longPressThreshold` seconds WITHOUT any
/// other modifier or key being involved. This prevents the panel from
/// appearing when the user is executing a regular ⌘X / ⌘S shortcut.
final class HotkeyManager {

    // MARK: - Tuning

    /// How long (in seconds) the user must hold ⌘ before the panel appears.
    private let longPressThreshold: TimeInterval = 0.4

    // MARK: - Events

    /// Fired when the Command key has been held long enough to count as a
    /// long-press (no other modifier pressed during the hold).
    var onCommandDown: (() -> Void)?

    /// Fired when the Command key transitions from down to up. Note that
    /// for a successful long-press this is fired after `onCommandDown`.
    var onCommandUp: (() -> Void)?

    /// Fired whenever any key is pressed (with or without modifiers).
    var onKeyPressed: ((NSEvent) -> Void)?

    /// Fired when the user clicks the mouse outside the panel.
    var onMouseClicked: ((NSEvent) -> Void)?

    // MARK: - Private state

    private var flagsMonitor: Any?
    private var keyMonitor: Any?
    private var mouseMonitor: Any?

    private var wasCommandDown = false
    /// Tracks whether ⌘ was held alone (no other modifiers) when the press
    /// started, so we can cancel the timer if another modifier appears.
    private var wasCommandAlone = false
    private var longPressTimer: Timer?
    private(set) var isRunning = false

    // MARK: - Lifecycle

    func start() {
        guard !isRunning else { return }
        isRunning = true

        // 1. Modifier key transitions.
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return }
            let cmdDown = event.modifierFlags.contains(.command)
            let otherModifiersDown = !event.modifierFlags
                .subtracting(.command)
                .isDisjoint(with: [.shift, .control, .option])

            // Press edge: ⌘ just went down.
            if cmdDown && !self.wasCommandDown {
                if otherModifiersDown {
                    // ⌘ pressed while another modifier was already held —
                    // not a long-press intent (user is composing a combo).
                    self.wasCommandAlone = false
                } else {
                    self.wasCommandAlone = true
                    self.scheduleLongPress()
                }
            }
            // Release edge: ⌘ just went up.
            else if !cmdDown && self.wasCommandDown {
                self.cancelLongPress()
                self.wasCommandAlone = false
                DispatchQueue.main.async { self.onCommandUp?() }
            }
            // ⌘ still down, but another modifier was added (e.g. ⌘→⌘⇧).
            // No longer a "long-press ⌘" intent; cancel the pending trigger.
            else if cmdDown && self.wasCommandDown && otherModifiersDown && self.wasCommandAlone {
                self.cancelLongPress()
                self.wasCommandAlone = false
            }

            self.wasCommandDown = cmdDown
        }

        // 2. Any key press — cancels pending long-press AND dismisses panel.
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.cancelLongPress()
            DispatchQueue.main.async { self?.onKeyPressed?(event) }
        }

        // 3. Mouse clicks outside the panel.
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            self?.cancelLongPress()
            DispatchQueue.main.async { self?.onMouseClicked?(event) }
        }
    }

    func stop() {
        cancelLongPress()
        if let m = flagsMonitor { NSEvent.removeMonitor(m) }
        if let m = keyMonitor   { NSEvent.removeMonitor(m) }
        if let m = mouseMonitor { NSEvent.removeMonitor(m) }
        flagsMonitor = nil
        keyMonitor = nil
        mouseMonitor = nil
        isRunning = false
    }

    deinit { stop() }

    // MARK: - Long-press helpers

    private func scheduleLongPress() {
        cancelLongPress()
        let timer = Timer.scheduledTimer(
            withTimeInterval: longPressThreshold,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            self.longPressTimer = nil
            // Only fire if ⌘ is still held alone at the moment of firing.
            if self.wasCommandDown && self.wasCommandAlone {
                DispatchQueue.main.async { self.onCommandDown?() }
            }
        }
        longPressTimer = timer
    }

    private func cancelLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}

// MARK: - Accessibility permission

extension HotkeyManager {

    /// Returns `true` if the process is trusted for Accessibility access.
    /// Without this, global event monitors will not deliver any events.
    static func hasAccessibilityPermission() -> Bool {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(opts as CFDictionary)
    }

    /// Opens the Accessibility pane in System Settings.
    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
