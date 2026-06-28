# CheatSheet — macOS 快捷键速查工具

一款基于 SwiftUI + AppKit 的菜单栏 App。在任意应用界面 **按住 ⌘ Command 键**，即可在光标附近弹出一个非模态面板，分类展示该应用的全部可用快捷键。按下任意按键即可关闭，不抢焦点、不影响当前应用。

## 功能特性

- **全局快捷键监听**：基于 `NSEvent.addGlobalMonitorForEvents` 实时监听 ⌘ 按下与任意键盘输入
- **精准应用识别**：通过 `NSWorkspace.frontmostApplication` 获取当前前台 App 的 bundleID 与本地化名称
- **非模态非激活面板**：使用 `.nonactivatingPanel` + `.utilityWindow`，按下快捷键时事件继续发往前台应用
- **分类展示**：快捷键按功能（File / Edit / View / Navigate …）分组，配 SF Symbol 图标
- **现代视觉**：NSVisualEffectView 毛玻璃背景 + Material 顶/底栏 + 圆角阴影 + Caps 键帽样式
- **低资源占用**：面板默认隐藏，仅在 ⌘ 按下时实例化内容，使用 `LazyVStack` 高效渲染
- **内置 20+ 应用数据**：Finder、Safari、Mail、Terminal、Xcode、VS Code、Pages/Numbers/Keynote、TextEdit、Preview、Notes、Photos、Music、Chrome、Firefox、Slack 等

## 文件结构

```
CheatSheet/
├── CheatSheetApp.swift      # @main 入口（accessory 模式）
├── AppDelegate.swift        # 协调器：菜单栏 / 事件回调 / 面板生命周期
├── HotkeyManager.swift      # 全局 ⌘/按键/鼠标事件监听 + 辅助功能权限检测
├── AppDetector.swift        # 当前前台 App 识别（NSWorkspace）
├── ShortcutDatabase.swift   # 内置 20+ 应用的快捷键字典
├── ShortcutPanel.swift      # NSPanel 子类（非激活、悬浮、光标定位）
├── ShortcutView.swift       # SwiftUI 视图（Header / 分类列表 / Footer）
├── Models.swift             # 数据模型（Shortcut / ShortcutCategory / FrontmostApp）
├── Info.plist               # App 元数据（LSUIElement=true）
└── README.md                # 本文件
```

## Xcode 项目搭建（推荐）

由于 Swift Package Manager 对 GUI App + NSPanel 的支持有限，建议用 Xcode 创建项目：

1. 打开 Xcode → **File ▸ New ▸ Project…**
2. 选择 **macOS ▸ App**，点 Next
3. 填写：
   - Product Name: `CheatSheet`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ⛔️ 取消勾选 "Include Tests"
4. 保存到本目录（`CheatSheet/CheatSheet.xcodeproj`）
5. **删除** Xcode 自动生成的 `CheatSheetApp.swift` 和 `ContentView.swift`
6. 将本目录中的所有 `.swift` 文件拖入 Xcode 工程（在 "Copy items if needed" 上打勾）
7. 替换 `Info.plist`：在工程设置 ▸ Target ▸ Info 中粘贴本文件的内容（或在 Build Settings 将 Info.plist File 指向本目录的 `Info.plist`）
8. **Signing & Capabilities** ▸ 勾选 **App Sandbox** 默认即可（无需额外能力；全局事件监听在辅助功能授权后即可工作）
9. **Run**（⌘R）

> ⚠️ 首次运行后，macOS 会提示「无法打开，因为来自身份不明的开发者」。请到 `系统设置 → 隐私与安全性` 下点击「仍要打开」。

## 首次使用：授予辅助功能权限

为了让 CheatSheet 能在其它应用前台时监听键盘事件，必须授予 **辅助功能 (Accessibility)** 权限：

1. 运行 CheatSheet 后会弹出提示，点击 **"打开系统设置"**
2. 在 **隐私与安全性 → 辅助功能** 中开启 **CheatSheet**
3. 重启 CheatSheet（或直接重新打开）

也可点击菜单栏图标 → **Open Accessibility Settings…**

## 使用方式

- **按住 ⌘ Command 键**：在任意应用中按住 ⌘，面板会在光标位置附近弹出
- **查看快捷键**：面板按功能分类展示，支持滚动浏览
- **使用快捷键**：保持 ⌘ 按下，再按其它键（如 ⌘S）—— 面板自动消失，快捷键正常发往前台应用
- **直接关闭**：在面板外点击鼠标 / 按 Esc 也会关闭
- **菜单栏图标**：点击 CheatSheet 菜单栏图标 → "Show Test Panel" 可不依赖辅助功能测试 UI

## 工作原理

```
⌘ 按下 → NSEvent.flagsChanged（global monitor）→ AppDelegate.handleCommandDown()
                                                              ↓
                                                  AppDetector.current()
                                                              ↓
                                          ShortcutDatabase.categories(for: bundleID)
                                                              ↓
                                        ShortcutView 嵌入 NSPanel，orderFrontRegardless()

任意 keyDown → NSEvent.keyDown（global monitor）→ AppDelegate.hidePanel()
                  ⚠️ 由于面板是 .nonactivatingPanel，按键事件同时被前台 App 接收
```

### 为什么不会拦截快捷键？

- `NSEvent.addGlobalMonitorForEvents` 只能 **观察**，无法 **拦截** 事件
- 面板采用 `.nonactivatingPanel` + `canBecomeKey = false`，永不抢焦点
- 因此用户在面板显示期间按下 ⌘S，事件流是：
  1. 前台 App（如 Safari）收到 `keyDown` ⌘S → 执行 "保存网页"
  2. 全局监听器同时收到 `keyDown` 通知 → 隐藏 CheatSheet 面板
- 用户体验：**面板自动消失 + 快捷键正常工作**，正是预期行为

## 资源占用

- App 进程内存：~25 MB（SwiftUI + AppKit 基础开销）
- CPU 占用：仅在 ⌘ 按下/释放/键盘事件时短暂唤醒（毫秒级）
- 空闲时：0% CPU，几乎无网络/磁盘活动

## 扩展快捷键数据

在 `ShortcutDatabase.swift` 的 `buildRegistry()` 方法中按以下格式添加：

```swift
r["com.example.MyApp"] = [
    ShortcutCategory(name: "File", symbol: "doc", shortcuts: [
        Shortcut(keys: "⌘N", title: "New"),
        Shortcut(keys: "⌘S", title: "Save"),
    ]),
    // ...
]
```

快捷键修饰符符号参考：

| 符号 | 含义   | 符号 | 含义       |
| ---- | ------ | ---- | ---------- |
| ⌘    | Command | ⇧    | Shift      |
| ⌥    | Option | ⌃    | Control    |
| ⇥    | Tab    | ⏎    | Return     |
| ⌫    | Delete | ⎋    | Escape     |

## 系统要求

- macOS 12.0 Monterey 或更高版本
- 需要授予「辅助功能」权限
