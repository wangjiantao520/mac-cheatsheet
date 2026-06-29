import AppKit

/// Listens for ⌘ Command / ⌃ Control key state changes and any subsequent
/// key presses across the entire system. Global monitors can only OBSERVE
/// events, not consume them — which is exactly what we want so that the
/// frontmost application still receives the keystroke.
///
/// Long-press semantics: `onCommandDown` only fires after the user has
/// held ⌘ OR ⌃ continuously for `longPressThreshold` seconds, with no
/// other modifier (⇧ / ⌥ / the other trigger key) involved. This prevents
/// the panel from appearing when the user is executing a regular ⌘X / ⌘S
/// shortcut, or a ⌘⌃ / ⌃⇧ combo.
final class HotkeyManager {

    // MARK: - Tuning

    /// How long (in seconds) the user must hold ⌘ or ⌃ before the panel appears.
    private let longPressThreshold: TimeInterval = 0.4

    // MARK: - Events

    /// Fired when ⌘ or ⌃ has been held long enough to count as a long-press
    /// (no other modifier pressed during the hold, only one trigger key down).
    var onCommandDown: (() -> Void)?

    /// Fired when the trigger key (⌘ or ⌃) is released.
    /// Note that for a successful long-press this is fired after `onCommandDown`.
    var onCommandUp: (() -> Void)?

    /// Fired whenever any key is pressed (with or without modifiers).
    var onKeyPressed: ((NSEvent) -> Void)?

    /// Fired when the user clicks the mouse outside the panel.
    var onMouseClicked: ((NSEvent) -> Void)?

    // MARK: - Private state

    private var flagsMonitor: Any?
    private var keyMonitor: Any?
    private var mouseMonitor: Any?

    private var wasCmdDown = false
    private var wasCtrlDown = false
    /// True when exactly one of ⌘/⌃ is down and no shift/option is pressed.
    private var wasTriggerAlone = false
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
            let ctrlDown = event.modifierFlags.contains(.control)
            let triggerCount = (cmdDown ? 1 : 0) + (ctrlDown ? 1 : 0)
            // ⇧ / ⌥ are never trigger keys — treat them as combo modifiers.
            let otherModifiersDown = !event.modifierFlags
                .subtracting([.command, .control])
                .isDisjoint(with: [.shift, .option])

            let triggerActive = triggerCount > 0
            let wasTriggerActive = self.wasCmdDown || self.wasCtrlDown

            // Press edge: a trigger key (⌘ or ⌃) just went down.
            if triggerActive && !wasTriggerActive {
                if otherModifiersDown || triggerCount > 1 {
                    // ⌘ or ⌃ pressed along with another modifier / trigger key —
                    // user is composing a combo, not requesting a long-press.
                    self.wasTriggerAlone = false
                } else {
                    self.wasTriggerAlone = true
                    self.scheduleLongPress()
                }
            }
            // Release edge: every trigger key released.
            else if !triggerActive && wasTriggerActive {
                self.cancelLongPress()
                self.wasTriggerAlone = false
                DispatchQueue.main.async { self.onCommandUp?() }
            }
            // Trigger still held, but combo detected (added ⇧/⌥, or second trigger).
            else if triggerActive && wasTriggerActive {
                if (otherModifiersDown || triggerCount > 1) && self.wasTriggerAlone {
                    self.cancelLongPress()
                    self.wasTriggerAlone = false
                }
            }

            self.wasCmdDown = cmdDown
            self.wasCtrlDown = ctrlDown
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
            // Only fire if exactly one trigger key is still held alone.
            if self.wasTriggerAlone {
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
