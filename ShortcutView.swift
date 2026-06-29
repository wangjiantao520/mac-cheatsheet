import SwiftUI

// MARK: - Root View

struct ShortcutView: View {
    let app: FrontmostApp
    let categories: [ShortcutCategory]

    // Live settings: when SettingsStore mutates, ShortcutView re-renders.
    @ObservedObject private var store = SettingsStore.shared

    var body: some View {
        VStack(spacing: 0) {
            HeaderBar(app: app)
            Divider().opacity(0.25)
            CategoryList(
                categories: categories,
                fontSize: store.settings.shortcutFontSize,
                keyCapFontSize: store.settings.keyCapFontSize,
                textColor: store.settings.resolvedTextColor,
                keyCapColor: store.settings.resolvedKeyCapColor,
                defaultCollapsed: store.settings.collapseCategories
            )
            FooterBar()
        }
        .frame(width: 480, height: 540)
        .background(WindowBackground())
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }
}

// MARK: - Header

private struct HeaderBar: View {
    let app: FrontmostApp

    var body: some View {
        HStack(spacing: 12) {
            // App icon, gracefully falls back to a generic SF Symbol.
            Group {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 1) {
                Text(app.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("键盘快捷键")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 5) {
                KeyCap(text: "⌘", fontSize: 11.5, color: .primary)
                Text("长按以显示")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(Color.primary.opacity(0.06))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Categories

private struct CategoryList: View {
    let categories: [ShortcutCategory]
    let fontSize: Double
    let keyCapFontSize: Double
    let textColor: Color
    let keyCapColor: Color
    let defaultCollapsed: Bool

    var body: some View {
        ScrollView(showsIndicators: true) {
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(categories) { category in
                    CategorySection(
                        category: category,
                        fontSize: fontSize,
                        keyCapFontSize: keyCapFontSize,
                        textColor: textColor,
                        keyCapColor: keyCapColor,
                        defaultCollapsed: defaultCollapsed
                    )
                }

                if categories.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text("该应用暂无可用快捷键")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
    }
}

private struct CategorySection: View {
    let category: ShortcutCategory
    let fontSize: Double
    let keyCapFontSize: Double
    let textColor: Color
    let keyCapColor: Color
    let defaultCollapsed: Bool

    @State private var isCollapsed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row — clicking toggles collapse state.
            Button(action: { isCollapsed.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 10)
                    Image(systemName: category.symbol)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(category.name.uppercased())
                        .font(.system(size: 10.5, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 4)
            }
            .buttonStyle(.plain)

            if !isCollapsed {
                VStack(spacing: 0) {
                    ForEach(Array(category.shortcuts.enumerated()), id: \.element.id) { index, shortcut in
                        ShortcutRow(
                            shortcut: shortcut,
                            fontSize: fontSize,
                            keyCapFontSize: keyCapFontSize,
                            textColor: textColor,
                            keyCapColor: keyCapColor
                        )
                        if index < category.shortcuts.count - 1 {
                            Divider().opacity(0.18).padding(.leading, 14)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.045))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
                )
            }
        }
        .onAppear {
            isCollapsed = defaultCollapsed
        }
    }
}

private struct ShortcutRow: View {
    let shortcut: Shortcut
    let fontSize: Double
    let keyCapFontSize: Double
    let textColor: Color
    let keyCapColor: Color

    var body: some View {
        HStack {
            Text(shortcut.title)
                .font(.system(size: fontSize))
                .foregroundStyle(textColor)
            Spacer(minLength: 12)
            KeyComboDisplay(
                text: shortcut.keys,
                keyCapFontSize: keyCapFontSize,
                keyCapColor: keyCapColor
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }
}

private struct KeyComboDisplay: View {
    let text: String
    let keyCapFontSize: Double
    let keyCapColor: Color

    var body: some View {
        let parts = text
            .split(whereSeparator: { $0 == " " })
            .map(String.init)
            .filter { !$0.isEmpty }

        HStack(spacing: 4) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                KeyCap(text: part, fontSize: keyCapFontSize, color: keyCapColor)
            }
        }
    }
}

private struct KeyCap: View {
    let text: String
    let fontSize: Double
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .medium, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 2.5)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.primary.opacity(0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5)
            )
    }
}

// MARK: - Footer

private struct FooterBar: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("按任意快捷键即可使用")
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
            Spacer()
            Text("ESC")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.primary.opacity(0.07)))
                .overlay(Capsule().strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
            Text("可关闭面板")
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Background

/// A NSVisualEffectView wrapper for a vibrant frosted background.
private struct WindowBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .popover
        v.state = .active
        v.blendingMode = .behindWindow
        v.isEmphasized = true
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = .popover
    }
}
