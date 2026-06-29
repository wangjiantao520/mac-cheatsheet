//
//  LaunchAtLoginHelper.swift
//  CheatSheet
//
//  Thin wrapper around `SMAppService.mainApp` (macOS 13+) so the Settings
//  UI can read/write the "launch at login" toggle without dragging AppKit
//  in directly. Falls back gracefully on macOS 12 (returns false / no-op).
//

import Foundation

#if canImport(ServiceManagement)
import ServiceManagement
#endif

enum LaunchAtLoginHelper {

    /// Whether the OS reports this app as a registered login item.
    /// Returns `false` on macOS < 13 (no SMAppService support).
    static var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    /// Register or unregister this app as a login item. The actual write
    /// happens on the main thread because SMAppService APIs require it.
    static func setEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if enabled {
                    if service.status != .enabled {
                        try service.register()
                    }
                } else {
                    if service.status == .enabled {
                        try service.unregister()
                    }
                }
            } catch {
                NSLog("CheatSheet: launch-at-login toggle failed: \(error.localizedDescription)")
            }
        }
        // macOS 12: silently no-op. Users can drag the .app into
        // System Settings → General → Login Items manually.
    }
}
