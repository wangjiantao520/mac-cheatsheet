//
//  Settings.swift
//  CheatSheet
//
//  Persistent user preferences. Backed by UserDefaults; broadcast changes
//  through Notification.Name.settingsDidChange so SwiftUI views and the
//  HotkeyManager can react in real-time.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Notification

extension Notification.Name {
    /// Fired after any field in `SettingsStore` mutates. UserInfo carries
    /// the changed `Settings` snapshot under the `settings` key.
    static let settingsDidChange = Notification.Name("CheatSheet.settingsDidChange")
}

// MARK: - Model

struct Settings: Equatable, Codable {

    // MARK: Trigger
    /// When true, ⌘/⌃ must be held for `longPressThreshold` seconds.
    /// When false, a single press of ⌘/⌃ shows the panel immediately.
    var requireLongPress: Bool
    /// Seconds the trigger key must be held before the panel appears.
    var longPressThreshold: Double

    // MARK: Appearance
    /// Base font size in points for the shortcut rows.
    var shortcutFontSize: Double
    /// Base font size in points for the section headers.
    var headerFontSize: Double
    /// Base font size in points for the key-cap labels.
    var keyCapFontSize: Double
    /// Hex string like "#1A1A1A" for the primary text color. Empty = use system.
    var textColorHex: String
    /// Hex string like "#3A3A3A" for the key-cap fill. Empty = use system.
    var keyCapColorHex: String

    // MARK: General
    /// Whether to fold all shortcut categories by default.
    var collapseCategories: Bool
    /// Register the app as a login item (macOS 13+).
    var launchAtLogin: Bool

    static let `default` = Settings(
        requireLongPress: true,
        longPressThreshold: 0.4,
        shortcutFontSize: 12.5,
        headerFontSize: 10.5,
        keyCapFontSize: 11.5,
        textColorHex: "",
        keyCapColorHex: "",
        collapseCategories: false,
        launchAtLogin: false
    )
}

// MARK: - Store

/// Observable wrapper around `Settings` that persists every change to
/// UserDefaults and broadcasts `settingsDidChange` so the rest of the app
/// (HotkeyManager, ShortcutView, AppDelegate) can react.
final class SettingsStore: ObservableObject {

    @Published var settings: Settings

    private let defaultsKey = "CheatSheet.settings.v1"
    private var cancellables: Set<AnyCancellable> = []

    static let shared = SettingsStore()

    init() {
        self.settings = Self.load()
        wireUpPersistence()
    }

    // MARK: - Public helpers

    /// Mutate one or more fields and persist + broadcast atomically.
    func update(_ mutate: (inout Settings) -> Void) {
        var copy = settings
        mutate(&copy)
        guard copy != settings else { return }
        settings = copy
        persist()
    }

    // MARK: - Persistence

    private static func load() -> Settings {
        guard
            let data = UserDefaults.standard.data(forKey: "CheatSheet.settings.v1"),
            let decoded = try? JSONDecoder().decode(Settings.self, from: data)
        else {
            return .default
        }
        // Merge in case the schema grew: any missing field falls back to default.
        return Settings(
            requireLongPress: decoded.requireLongPress,
            longPressThreshold: clamped(decoded.longPressThreshold, 0.1, 1.0),
            shortcutFontSize: clamped(decoded.shortcutFontSize, 9, 22),
            headerFontSize: clamped(decoded.headerFontSize, 8, 18),
            keyCapFontSize: clamped(decoded.keyCapFontSize, 8, 22),
            textColorHex: decoded.textColorHex,
            keyCapColorHex: decoded.keyCapColorHex,
            collapseCategories: decoded.collapseCategories,
            launchAtLogin: decoded.launchAtLogin
        )
    }

    private static func clamped<T: Comparable>(_ v: T, _ lo: T, _ hi: T) -> T {
        return min(max(v, lo), hi)
    }

    private func wireUpPersistence() {
        // Persist on every change, but coalesce rapid edits onto the main runloop.
        $settings
            .removeDuplicates()
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] new in
                guard let self = self else { return }
                self.persist(snapshot: new)
            }
            .store(in: &cancellables)
    }

    private func persist(snapshot: Settings? = nil) {
        let value = snapshot ?? settings
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
        NotificationCenter.default.post(
            name: .settingsDidChange,
            object: nil,
            userInfo: ["settings": value]
        )
    }
}

// MARK: - Color helpers

extension Settings {
    /// Decodes `textColorHex` into a SwiftUI `Color`, falling back to `.primary`.
    var resolvedTextColor: Color {
        Color(hex: textColorHex) ?? .primary
    }

    /// Decodes `keyCapColorHex` into a SwiftUI `Color`, falling back to `.primary`.
    var resolvedKeyCapColor: Color {
        Color(hex: keyCapColorHex) ?? .primary
    }
}

extension Color {
    /// Initialize from "#RRGGBB" or "#AARRGGBB". Returns nil for malformed input.
    init?(hex: String) {
        var trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("#") { trimmed.removeFirst() }
        guard trimmed.count == 6 || trimmed.count == 8 else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: trimmed).scanHexInt64(&value) else { return nil }

        let r, g, b, a: Double
        if trimmed.count == 6 {
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >> 8) & 0xFF) / 255.0
            b = Double(value & 0xFF) / 255.0
            a = 1.0
        } else {
            r = Double((value >> 24) & 0xFF) / 255.0
            g = Double((value >> 16) & 0xFF) / 255.0
            b = Double((value >> 8) & 0xFF) / 255.0
            a = Double(value & 0xFF) / 255.0
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
