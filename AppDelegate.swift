import AppKit
import SwiftUI
import QuartzCore

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Sub-components

    private let hotkeyManager = HotkeyManager()
    private var panel: ShortcutPanel!
    private var statusItem: NSStatusItem!

    // Cached SwiftUI hosting view + bundle id of the currently-rendered app,
    // so re-showing the panel for the same frontmost app is instant.
    private var contentHost: NSHostingView<AnyView>?
    private var contentBundleID: String?

    // Fade durations — kept short so the panel feels responsive.
    private let fadeInDuration: TimeInterval = 0.08
    private let fadeOutDuration: TimeInterval = 0.08

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Status-bar item with menu (no Dock icon — accessory app).
        setupStatusItem()

        // 2. Create the floating panel once; we mutate its contents at show time.
        panel = ShortcutPanel(contentSize: NSSize(width: 480, height: 540))

        // 3. Wire up hot-key events.
        hotkeyManager.onCommandDown   = { [weak self] in self?.handleCommandDown() }
        hotkeyManager.onCommandUp     = { [weak self] in self?.handleCommandUp() }
        hotkeyManager.onKeyPressed    = { [weak self] _ in self?.hidePanel() }
        hotkeyManager.onMouseClicked  = { [weak self] _ in self?.hidePanel() }
        hotkeyManager.start()

        // 4. Ensure Accessibility permission, prompt if missing.
        ensureAccessibilityPermission()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.stop()
    }

    // MARK: - Status bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let img = NSImage(systemSymbolName: "keyboard",
                              accessibilityDescription: "CheatSheet")
            img?.isTemplate = true
            button.image = img
            button.toolTip = "CheatSheet — 在任意应用中长按 ⌘ 或 ⌃ 查看快捷键"
        }

        let menu = NSMenu()

        let enableItem = NSMenuItem(
            title: "在任意应用中长按 ⌘ 或 ⌃ 查看快捷键",
            action: nil,
            keyEquivalent: ""
        )
        enableItem.isEnabled = false
        menu.addItem(enableItem)

        menu.addItem(.separator())

        let testItem = NSMenuItem(
            title: "显示测试面板",
            action: #selector(showTestPanel),
            keyEquivalent: "t"
        )
        testItem.target = self
        menu.addItem(testItem)

        let permItem = NSMenuItem(
            title: "打开辅助功能设置…",
            action: #selector(openAccessibilitySettings),
            keyEquivalent: ""
        )
        permItem.target = self
        menu.addItem(permItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "退出 CheatSheet",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Show / hide

    private func handleCommandDown() {
        // Throttle: only act if panel isn't already on screen.
        guard !panel.isVisible else { return }
        showPanel()
    }

    private func handleCommandUp() {
        // Long-press UX: as soon as ⌘ / ⌃ is released, dismiss the panel.
        hidePanel()
    }

    private func showPanel() {
        guard let app = AppDetector.current() else { return }

        // Never show our own panel over our own UI.
        if AppDetector.isSelf(app.bundleIdentifier) { return }

        // Reuse the previously built hosting view when the frontmost app
        // hasn't changed — avoids re-running the SwiftUI diff/render path.
        if contentBundleID != app.bundleIdentifier {
            let categories = ShortcutDatabase.shared.categories(for: app.bundleIdentifier)
            let view = ShortcutView(app: app, categories: categories)
            let host = NSHostingView(rootView: AnyView(view))
            host.autoresizingMask = [.width, .height]
            host.translatesAutoresizingMaskIntoConstraints = true
            panel.contentView = host
            host.frame = panel.contentView?.bounds ?? .zero
            contentHost = host
            contentBundleID = app.bundleIdentifier
        }

        panel.positionNearCursor()
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = fadeInDuration
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1.0
        }
    }

    private func hidePanel() {
        guard panel.isVisible else { return }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = fadeOutDuration
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0.0
        } completionHandler: { [weak self] in
            guard let self = self else { return }
            // Guard against being re-shown mid-fade.
            if self.panel.alphaValue < 0.5 {
                self.panel.orderOut(nil)
                self.panel.alphaValue = 1.0
            }
        }
    }

    // MARK: - Accessibility

    private func ensureAccessibilityPermission() {
        // Defer slightly so the alert appears after the UI is fully up.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            if HotkeyManager.hasAccessibilityPermission() { return }

            let alert = NSAlert()
            alert.messageText = "需要辅助功能权限"
            alert.informativeText = """
            CheatSheet 需要「辅助功能」权限才能监听全局键盘事件。

            请在 系统设置 → 隐私与安全性 → 辅助功能 中允许 CheatSheet。
            """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "打开系统设置")
            alert.addButton(withTitle: "稍后")

            if alert.runModal() == .alertFirstButtonReturn {
                HotkeyManager.openAccessibilitySettings()
            }
        }
    }

    // MARK: - Menu actions

    @objc private func showTestPanel() {
        // For testing without holding ⌘ in another app.
        let app = AppDetector.current() ?? FrontmostApp.unknown
        let categories = ShortcutDatabase.shared.categories(for: app.bundleIdentifier)
        panel.setContent(ShortcutView(app: app, categories: categories))
        panel.positionNearCursor()
        panel.orderFrontRegardless()
    }

    @objc private func openAccessibilitySettings() {
        HotkeyManager.openAccessibilitySettings()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
