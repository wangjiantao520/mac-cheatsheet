//
//  SettingsWindowController.swift
//  CheatSheet
//
//  A small AppKit window controller that hosts the SwiftUI SettingsView.
//  Singleton: the preferences window is a singleton — opening it twice
//  just brings the existing window forward.
//

import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController {

    static let shared = SettingsWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 380),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "CheatSheet 偏好设置"
        window.isReleasedWhenClosed = false
        window.center()
        window.titlebarAppearsTransparent = false
        window.appearance = nil  // follow system

        let host = NSHostingView(rootView: SettingsView())
        host.autoresizingMask = [.width, .height]
        host.translatesAutoresizingMaskIntoConstraints = true
        window.contentView = host
        host.frame = window.contentView?.bounds ?? .zero

        super.init(window: window)
    }

    required init?(coder: NSCoder) { fatalError() }

    /// Open the window, bringing it forward if already visible.
    func show() {
        guard let win = window else { return }
        if win.isVisible {
            // Bring to front and activate so the user sees it.
            NSApp.activate(ignoringOtherApps: true)
            win.makeKeyAndOrderFront(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            win.center()
            win.makeKeyAndOrderFront(nil)
        }
    }
}
