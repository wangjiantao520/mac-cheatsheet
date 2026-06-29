//
//  SettingsView.swift
//  CheatSheet
//
//  The preferences window content. A single, lightweight TabView with
//  three tabs: 触发 / 外观 / 通用.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @State private var selectedTab: Tab = .trigger

    enum Tab: String, CaseIterable, Identifiable {
        case trigger = "触发"
        case appearance = "外观"
        case general = "通用"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider().opacity(0.2)
            ScrollView {
                Group {
                    switch selectedTab {
                    case .trigger:    TriggerTab(settings: store.settings, store: store)
                    case .appearance: AppearanceTab(settings: store.settings, store: store)
                    case .general:    GeneralTab(settings: store.settings, store: store)
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 460, height: 380)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(.system(size: 12, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            Rectangle()
                                .fill(selectedTab == tab
                                      ? Color.accentColor.opacity(0.10)
                                      : Color.clear)
                        )
                        .overlay(
                            Rectangle()
                                .fill(selectedTab == tab ? Color.accentColor : .clear)
                                .frame(height: 2),
                            alignment: .bottom
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Trigger Tab

private struct TriggerTab: View {
    let settings: Settings
    let store: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            section(title: "触发方式") {
                Toggle(isOn: binding(\.requireLongPress)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("长按 ⌘ 或 ⌃ 触发")
                            .font(.system(size: 12.5))
                        Text("关闭后，按一下即触发弹窗")
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
            }

            section(title: "长按阈值") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Slider(
                            value: binding(\.longPressThreshold),
                            in: 0.1...1.0
                        )
                        .disabled(!settings.requireLongPress)
                        Text(String(format: "%.2f 秒", settings.longPressThreshold))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 64, alignment: .trailing)
                    }
                    Text("按住 ⌘ 或 ⌃ 达到该时长后弹窗出现。建议 0.3 ~ 0.5 秒。")
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    private func binding<V>(_ keyPath: WritableKeyPath<Settings, V>) -> Binding<V> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in store.update { $0[keyPath: keyPath] = newValue } }
        )
    }
}

// MARK: - Appearance Tab

private struct AppearanceTab: View {
    let settings: Settings
    let store: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            section(title: "字号") {
                VStack(alignment: .leading, spacing: 10) {
                    sizeRow(
                        label: "快捷键文字",
                        value: binding(\.shortcutFontSize),
                        range: 9...18
                    )
                    sizeRow(
                        label: "分组标题",
                        value: binding(\.headerFontSize),
                        range: 8...16
                    )
                    sizeRow(
                        label: "按键标签",
                        value: binding(\.keyCapFontSize),
                        range: 8...18
                    )
                }
            }

            section(title: "颜色") {
                VStack(alignment: .leading, spacing: 10) {
                    colorRow(
                        label: "文字颜色",
                        hex: binding(\.textColorHex)
                    )
                    colorRow(
                        label: "按键标签底色",
                        hex: binding(\.keyCapColorHex)
                    )
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        Text("留空则跟随系统外观（深色/浅色自动切换）")
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
    }

    private func sizeRow(label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .frame(width: 80, alignment: .leading)
            Slider(value: value, in: range)
            Text(String(format: "%.0f pt", value.wrappedValue))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 48, alignment: .trailing)
        }
    }

    private func colorRow(label: String, hex: Binding<String>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .frame(width: 80, alignment: .leading)
            ColorPicker(
                "",
                selection: Binding(
                    get: { Color(hex: hex.wrappedValue) ?? .primary },
                    set: { newColor in
                        hex.wrappedValue = newColor.toHexString() ?? ""
                    }
                ),
                supportsOpacity: false
            )
            .labelsHidden()
            .frame(width: 44)
            TextField(
                "#RRGGBB",
                text: hex
            )
            .textFieldStyle(.roundedBorder)
            .font(.system(size: 11, design: .monospaced))
            .frame(width: 100)
            Button("重置") {
                hex.wrappedValue = ""
            }
            .controlSize(.small)
        }
    }

    private func binding<V>(_ keyPath: WritableKeyPath<Settings, V>) -> Binding<V> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in store.update { $0[keyPath: keyPath] = newValue } }
        )
    }
}

// MARK: - General Tab

private struct GeneralTab: View {
    let settings: Settings
    let store: SettingsStore

    @State private var launchAtLoginAvailable = true
    @State private var launchAtLoginError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            section(title: "快捷键列表") {
                Toggle(isOn: binding(\.collapseCategories)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("默认折叠所有分组")
                            .font(.system(size: 12.5))
                        Text("弹窗出现时所有分组默认收起，点击分组标题展开")
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
            }

            section(title: "开机自启") {
                Toggle(isOn: launchAtLoginBinding) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("登录 macOS 时自动启动 CheatSheet")
                            .font(.system(size: 12.5))
                        if !launchAtLoginAvailable {
                            Text("需要 macOS 13 或更高版本")
                                .font(.system(size: 10.5))
                                .foregroundStyle(.secondary)
                        } else if let err = launchAtLoginError {
                            Text(err)
                                .font(.system(size: 10.5))
                                .foregroundStyle(.red)
                        }
                    }
                }
                .toggleStyle(.switch)
                .disabled(!launchAtLoginAvailable)
            }

            Spacer()
        }
        .onAppear {
            if #available(macOS 13.0, *) {
                launchAtLoginAvailable = true
            } else {
                launchAtLoginAvailable = false
            }
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { settings.launchAtLogin },
            set: { newValue in
                LaunchAtLoginHelper.setEnabled(newValue)
                // Re-read OS state — system may refuse (e.g. user cancelled
                // an authorization prompt). The toggle should reflect actual
                // state, not optimistic intent.
                let actual = LaunchAtLoginHelper.isEnabled
                store.update { $0.launchAtLogin = actual }
                if actual != newValue {
                    launchAtLoginError = "系统未接受开机自启设置，请在 系统设置 → 通用 → 登录项 中手动添加。"
                } else {
                    launchAtLoginError = nil
                }
            }
        )
    }

    private func binding<V>(_ keyPath: WritableKeyPath<Settings, V>) -> Binding<V> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in store.update { $0[keyPath: keyPath] = newValue } }
        )
    }
}

// MARK: - Reusable section header

@ViewBuilder
private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
        VStack(alignment: .leading, spacing: 8, content: content)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.045))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
    }
}

// MARK: - Color → Hex

private extension Color {
    /// Convert to "#RRGGBB". Returns nil for colors that can't be represented
    /// in sRGB (e.g. catalog colors outside the working space).
    func toHexString() -> String? {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        let r = Int(round(ns.redComponent * 255))
        let g = Int(round(ns.greenComponent * 255))
        let b = Int(round(ns.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
