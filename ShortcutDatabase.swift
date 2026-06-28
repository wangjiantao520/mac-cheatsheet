import Foundation

/// Provides shortcut data for known applications, with a generic fallback.
final class ShortcutDatabase {

    static let shared = ShortcutDatabase()

    // MARK: - Public API

    /// Returns categories tuned to the given bundle identifier. If no specific
    /// data is registered, returns a sensible default set of common shortcuts.
    func categories(for bundleID: String) -> [ShortcutCategory] {
        return registry[bundleID] ?? defaultCategories
    }

    // MARK: - Storage

    private let registry: [String: [ShortcutCategory]]

    private init() {
        self.registry = ShortcutDatabase.buildRegistry()
    }

    // MARK: - Defaults

    private var defaultCategories: [ShortcutCategory] {
        return [
            ShortcutCategory(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⇧⌘S", title: "另存为…"),
                .init(keys: "⌘P", title: "打印"),
                .init(keys: "⌘W", title: "关闭"),
                .init(keys: "⌘Q", title: "退出"),
            ]),
            ShortcutCategory(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⇧⌘Z", title: "重做"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
                .init(keys: "⌘F", title: "查找"),
            ]),
            ShortcutCategory(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘0", title: "实际大小"),
                .init(keys: "⌘+", title: "放大"),
                .init(keys: "⌘-", title: "缩小"),
                .init(keys: "⌘1", title: "进入全屏"),
            ]),
            ShortcutCategory(name: "窗口", symbol: "macwindow", shortcuts: [
                .init(keys: "⌘M", title: "最小化"),
                .init(keys: "⌘H", title: "隐藏"),
                .init(keys: "⌥⌘H", title: "隐藏其他"),
            ]),
        ]
    }

    // MARK: - Registry builder

    private static func buildRegistry() -> [String: [ShortcutCategory]] {
        var r: [String: [ShortcutCategory]] = [:]

        // ---------- Finder ----------
        r["com.apple.finder"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建访达窗口"),
                .init(keys: "⇧⌘N", title: "新建文件夹"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘W", title: "关闭窗口"),
                .init(keys: "⌘I", title: "显示简介"),
                .init(keys: "⌘D", title: "创建副本"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘1", title: "图标视图"),
                .init(keys: "⌘2", title: "列表视图"),
                .init(keys: "⌘3", title: "分栏视图"),
                .init(keys: "⌘4", title: "画廊视图"),
                .init(keys: "⌘J", title: "显示视图选项"),
                .init(keys: "⌘[", title: "后退"),
                .init(keys: "⌘]", title: "转发"),
            ]),
            .init(name: "跳转", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⇧⌘C", title: "电脑"),
                .init(keys: "⇧⌘H", title: "个人"),
                .init(keys: "⇧⌘O", title: "文稿"),
                .init(keys: "⇧⌘A", title: "应用程序"),
                .init(keys: "⌥⌘L", title: "下载"),
                .init(keys: "⌘↑", title: "上层文件夹"),
                .init(keys: "⌘↓", title: "打开所选项"),
            ]),
        ]

        // ---------- Safari ----------
        r["com.apple.Safari"] = [
            .init(name: "标签页", symbol: "rectangle.stack", shortcuts: [
                .init(keys: "⌘T", title: "新建标签页"),
                .init(keys: "⇧⌘T", title: "重新打开关闭的标签页"),
                .init(keys: "⌘W", title: "关闭标签页"),
                .init(keys: "⌥⌘W", title: "关闭其他标签页"),
                .init(keys: "⌃⇧Tab", title: "上一个标签页"),
                .init(keys: "⌃Tab", title: "下一个标签页"),
                .init(keys: "⇧⌘N", title: "新建窗口"),
            ]),
            .init(name: "导航", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⌘L", title: "聚焦到地址栏"),
                .init(keys: "⌘R", title: "重新载入页面"),
                .init(keys: "⇧⌘R", title: "忽略缓存重新载入"),
                .init(keys: "⌘.", title: "停止加载"),
                .init(keys: "⌘[", title: "后退"),
                .init(keys: "⌘]", title: "转发"),
                .init(keys: "⌘Home", title: "主页"),
            ]),
            .init(name: "书签", symbol: "book", shortcuts: [
                .init(keys: "⌘D", title: "添加书签"),
                .init(keys: "⇧⌘D", title: "为标签页添加书签"),
                .init(keys: "⌥⌘B", title: "显示书签"),
                .init(keys: "⌥⌘S", title: "显示阅读列表"),
                .init(keys: "⌥⌘F", title: "显示收藏"),
            ]),
            .init(name: "历史记录", symbol: "clock", shortcuts: [
                .init(keys: "⌘Y", title: "显示历史记录"),
                .init(keys: "⌥⌘E", title: "清空缓存"),
                .init(keys: "⌘⇧⌫", title: "清除历史记录"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘0", title: "实际大小"),
                .init(keys: "⌘+", title: "放大"),
                .init(keys: "⌘-", title: "缩小"),
                .init(keys: "⌘\\", title: "在 iPad 中显示同一标签页"),
            ]),
            .init(name: "窗口", symbol: "macwindow", shortcuts: [
                .init(keys: "⌘M", title: "最小化"),
                .init(keys: "⌘H", title: "隐藏 Safari"),
                .init(keys: "⌥⌘H", title: "隐藏其他"),
            ]),
        ]

        // ---------- Mail ----------
        r["com.apple.mail"] = [
            .init(name: "邮箱", symbol: "mail.stack", shortcuts: [
                .init(keys: "⌘N", title: "新建邮件"),
                .init(keys: "⇧⌘N", title: "新建邮箱"),
                .init(keys: "⌥⌘N", title: "新建便笺"),
            ]),
            .init(name: "邮件", symbol: "envelope", shortcuts: [
                .init(keys: "⌘R", title: "回复"),
                .init(keys: "⇧⌘R", title: "全部回复"),
                .init(keys: "⌥⌘R", title: "转发"),
                .init(keys: "⌘F", title: "转发"),
                .init(keys: "⌘D", title: "发送"),
                .init(keys: "⌘K", title: "添加附件"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘1", title: "显示邮箱"),
                .init(keys: "⌘2", title: "显示联系人"),
                .init(keys: "⌘3", title: "显示日历"),
                .init(keys: "⌥⌘T", title: "显示/隐藏待办栏"),
                .init(keys: "⌘/", title: "显示搜索"),
            ]),
        ]

        // ---------- Terminal ----------
        r["com.apple.Terminal"] = [
            .init(name: "终端", symbol: "terminal", shortcuts: [
                .init(keys: "⌘N", title: "新建窗口"),
                .init(keys: "⌘T", title: "新建标签页"),
                .init(keys: "⌘W", title: "关闭标签页"),
                .init(keys: "⌘D", title: "拆分窗格"),
                .init(keys: "⇧⌘D", title: "关闭分屏"),
                .init(keys: "⌃⌘⇧", title: "移至下一窗格"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌥⌘C", title: "拷贝带样式"),
                .init(keys: "⌘A", title: "全选"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘+", title: "更大字体"),
                .init(keys: "⌘-", title: "更小字体"),
                .init(keys: "⌘0", title: "默认字体"),
                .init(keys: "⌥⌘0", title: "默认主题"),
            ]),
        ]

        // ---------- Xcode ----------
        r["com.apple.dt.Xcode"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建文件"),
                .init(keys: "⇧⌘N", title: "新建项目"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⇧⌘K", title: "清理构建文件夹"),
            ]),
            .init(name: "构建", symbol: "hammer", shortcuts: [
                .init(keys: "⌘B", title: "构建"),
                .init(keys: "⌘R", title: "运行"),
                .init(keys: "⌘U", title: "测试"),
                .init(keys: "⌘I", title: "分析"),
                .init(keys: "⇧⌘A", title: "分析"),
                .init(keys: "⌘.", title: "停止"),
            ]),
            .init(name: "导航", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⌘0", title: "显示项目导航器"),
                .init(keys: "⌘1", title: "显示源代码导航器"),
                .init(keys: "⌘2", title: "显示符号导航器"),
                .init(keys: "⌘3", title: "显示查找导航器"),
                .init(keys: "⌘4", title: "显示问题导航器"),
                .init(keys: "⌘5", title: "显示测试导航器"),
                .init(keys: "⌘6", title: "显示调试导航器"),
                .init(keys: "⇧⌘O", title: "快速打开…"),
                .init(keys: "⌘⇧J", title: "在导航器中筛选"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘/", title: "注释所选内容"),
                .init(keys: "⌃I", title: "重新缩进"),
                .init(keys: "⌘[", title: "向左缩进"),
                .init(keys: "⌘]", title: "向右缩进"),
            ]),
            .init(name: "调试", symbol: "ladybug", shortcuts: [
                .init(keys: "F6", title: "单步跳过"),
                .init(keys: "F7", title: "单步进入"),
                .init(keys: "F8", title: "单步跳出"),
                .init(keys: "⌘\\", title: "切换断点"),
                .init(keys: "⌘Y", title: "显示/隐藏调试区域"),
            ]),
        ]

        // ---------- VS Code ----------
        r["com.microsoft.VSCode"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建文件"),
                .init(keys: "⌘O", title: "打开文件"),
                .init(keys: "⌘K ⌘O", title: "打开文件夹"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⌥⌘S", title: "全部保存"),
                .init(keys: "⌘W", title: "关闭"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⇧⌘Z", title: "重做"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘/", title: "切换行注释"),
                .init(keys: "⌥↑", title: "将行上移"),
                .init(keys: "⌥↓", title: "将行下移"),
                .init(keys: "⇧⌥↑", title: "向上复制行"),
                .init(keys: "⇧⌥↓", title: "向下复制行"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘B", title: "切换侧边栏"),
                .init(keys: "⌘J", title: "切换面板"),
                .init(keys: "⌃`", title: "切换终端"),
                .init(keys: "⌘⇧P", title: "命令面板"),
                .init(keys: "⌘P", title: "快速打开"),
                .init(keys: "⇧⌘P", title: "显示所有命令"),
            ]),
            .init(name: "查找", symbol: "magnifyingglass", shortcuts: [
                .init(keys: "⌘F", title: "查找"),
                .init(keys: "⌥⌘F", title: "替换"),
                .init(keys: "⇧⌘F", title: "在文件中查找"),
            ]),
            .init(name: "导航", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⌃G", title: "跳转到行"),
                .init(keys: "⌘T", title: "显示所有符号"),
                .init(keys: "⌃Tab", title: "切换编辑器"),
                .init(keys: "⌃-", title: "后退"),
                .init(keys: "⌃⇧-", title: "前进"),
            ]),
            .init(name: "调试", symbol: "ladybug", shortcuts: [
                .init(keys: "F5", title: "开始/继续"),
                .init(keys: "F9", title: "切换断点"),
                .init(keys: "F10", title: "单步跳过"),
                .init(keys: "F11", title: "单步进入"),
                .init(keys: "⇧F11", title: "单步跳出"),
                .init(keys: "⇧⌘D", title: "运行并调试"),
            ]),
        ]

        // ---------- Pages ----------
        r["com.apple.iWork.Pages"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建文档"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⇧⌘S", title: "创建副本"),
                .init(keys: "⌘P", title: "打印"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⇧⌘Z", title: "重做"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
            .init(name: "插入", symbol: "plus", shortcuts: [
                .init(keys: "⌥⌘T", title: "插入表格"),
                .init(keys: "⇧⌘L", title: "插入图表"),
                .init(keys: "⇧⌘K", title: "插入公式"),
                .init(keys: "⌥⌘I", title: "插入图像"),
            ]),
            .init(name: "格式", symbol: "textformat", shortcuts: [
                .init(keys: "⌘B", title: "加粗"),
                .init(keys: "⌘I", title: "斜体"),
                .init(keys: "⌘U", title: "下划线"),
                .init(keys: "⇧⌘C", title: "拷贝样式"),
                .init(keys: "⇧⌘V", title: "粘贴样式"),
            ]),
            .init(name: "排列", symbol: "rectangle.3.offgrid", shortcuts: [
                .init(keys: "⌥⌘↑", title: "置于顶层"),
                .init(keys: "⌥⌘↓", title: "置于底层"),
                .init(keys: "⌘[", title: "组合"),
                .init(keys: "⌘]", title: "取消组合"),
            ]),
        ]

        // ---------- Numbers ----------
        r["com.apple.iWork.Numbers"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建电子表格"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⇧⌘S", title: "创建副本"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⇧⌘Z", title: "重做"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘F", title: "查找"),
            ]),
            .init(name: "插入", symbol: "plus", shortcuts: [
                .init(keys: "⌥⌘N", title: "插入备注"),
                .init(keys: "⇧⌘L", title: "插入图表"),
                .init(keys: "⌥⌘T", title: "插入表格"),
                .init(keys: "⇧⌘K", title: "插入公式"),
            ]),
            .init(name: "表格", symbol: "tablecells", shortcuts: [
                .init(keys: "⌘A", title: "选择表格"),
                .init(keys: "⌘K", title: "上方添加行"),
                .init(keys: "⌘J", title: "前方添加列"),
                .init(keys: "⌥⌘C", title: "合并单元格"),
            ]),
        ]

        // ---------- Keynote ----------
        r["com.apple.iWork.Keynote"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建演示文稿"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⇧⌘Z", title: "重做"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘D", title: "创建副本"),
            ]),
            .init(name: "播放", symbol: "play", shortcuts: [
                .init(keys: "⌥⌘P", title: "播放幻灯片"),
                .init(keys: "⌘.", title: "停止幻灯片放映"),
                .init(keys: "→", title: "下一张幻灯片"),
                .init(keys: "←", title: "上一张幻灯片"),
            ]),
            .init(name: "插入", symbol: "plus", shortcuts: [
                .init(keys: "⇧⌘N", title: "新建幻灯片"),
                .init(keys: "⌥⌘T", title: "插入表格"),
                .init(keys: "⇧⌘L", title: "插入图表"),
            ]),
        ]

        // ---------- TextEdit ----------
        r["com.apple.TextEdit"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "新建"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⇧⌘T", title: "显示字体"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⇧⌘Z", title: "重做"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
                .init(keys: "⌘F", title: "查找"),
            ]),
            .init(name: "格式", symbol: "textformat", shortcuts: [
                .init(keys: "⌘B", title: "加粗"),
                .init(keys: "⌘I", title: "斜体"),
                .init(keys: "⌘U", title: "下划线"),
            ]),
        ]

        // ---------- Preview ----------
        r["com.apple.Preview"] = [
            .init(name: "文件", symbol: "doc", shortcuts: [
                .init(keys: "⌘N", title: "从剪贴板新建"),
                .init(keys: "⌘O", title: "打开"),
                .init(keys: "⌘S", title: "保存"),
                .init(keys: "⇧⌘S", title: "另存为"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘0", title: "实际大小"),
                .init(keys: "⌘9", title: "适合窗口"),
                .init(keys: "⌘+", title: "放大"),
                .init(keys: "⌘-", title: "缩小"),
                .init(keys: "⌥⌘2", title: "双页显示"),
                .init(keys: "⌥⌘1", title: "连续滚动"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
        ]

        // ---------- Notes ----------
        r["com.apple.Notes"] = [
            .init(name: "笔记", symbol: "note.text", shortcuts: [
                .init(keys: "⌘N", title: "新建便笺"),
                .init(keys: "⇧⌘N", title: "新建文件夹"),
                .init(keys: "⌘D", title: "创建副本"),
                .init(keys: "⌘R", title: "显示附件"),
                .init(keys: "⌫", title: "删除便笺"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
                .init(keys: "⌘F", title: "查找"),
            ]),
            .init(name: "格式", symbol: "textformat", shortcuts: [
                .init(keys: "⌘B", title: "加粗"),
                .init(keys: "⌘I", title: "斜体"),
                .init(keys: "⌘U", title: "下划线"),
                .init(keys: "⇧⌘T", title: "标题样式"),
                .init(keys: "⌃⇧H", title: "标题"),
            ]),
        ]

        // ---------- Photos ----------
        r["com.apple.Photos"] = [
            .init(name: "照片", symbol: "photo.on.rectangle", shortcuts: [
                .init(keys: "⌘N", title: "新建相册"),
                .init(keys: "⇧⌘N", title: "新建文件夹"),
                .init(keys: "⌘R", title: "旋转"),
                .init(keys: "⌘D", title: "创建副本"),
                .init(keys: "⌫", title: "删除"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘1", title: "年份"),
                .init(keys: "⌘2", title: "月份"),
                .init(keys: "⌘3", title: "日期"),
                .init(keys: "⌘4", title: "所有照片"),
                .init(keys: "⌥⌘0", title: "缩放照片"),
            ]),
        ]

        // ---------- Music ----------
        r["com.apple.Music"] = [
            .init(name: "播放控制", symbol: "play", shortcuts: [
                .init(keys: "Space", title: "播放/暂停"),
                .init(keys: "→", title: "下一首"),
                .init(keys: "←", title: "上一首"),
                .init(keys: "⌥→", title: "下一张专辑"),
                .init(keys: "⌥←", title: "上一张专辑"),
            ]),
            .init(name: "资料库", symbol: "music.note.list", shortcuts: [
                .init(keys: "⌘N", title: "新建播放列表"),
                .init(keys: "⌥⌘N", title: "新建智能播放列表"),
                .init(keys: "⌘F", title: "查找"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘0", title: "显示/隐藏状态栏"),
                .init(keys: "⌘1", title: "显示/隐藏侧边栏"),
                .init(keys: "⌥⌘F", title: "进入全屏"),
            ]),
        ]

        // ---------- Chrome ----------
        r["com.google.Chrome"] = [
            .init(name: "标签页", symbol: "rectangle.stack", shortcuts: [
                .init(keys: "⌘T", title: "新建标签页"),
                .init(keys: "⇧⌘T", title: "重新打开关闭的标签页"),
                .init(keys: "⌘W", title: "关闭标签页"),
                .init(keys: "⌥⌘W", title: "关闭其他标签页"),
                .init(keys: "⌃⇧Tab", title: "上一个标签页"),
                .init(keys: "⌃Tab", title: "下一个标签页"),
                .init(keys: "⌘M", title: "最小化窗口"),
            ]),
            .init(name: "导航", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⌘L", title: "聚焦到地址栏"),
                .init(keys: "⌘R", title: "重新载入"),
                .init(keys: "⇧⌘R", title: "强制重新载入"),
                .init(keys: "⌘.", title: "停止"),
                .init(keys: "⌘[", title: "后退"),
                .init(keys: "⌘]", title: "转发"),
                .init(keys: "⌥←", title: "上一个历史记录"),
                .init(keys: "⌥→", title: "下一个历史记录"),
            ]),
            .init(name: "书签", symbol: "book", shortcuts: [
                .init(keys: "⌘D", title: "为当前页添加书签"),
                .init(keys: "⇧⌘D", title: "为所有标签页添加书签"),
                .init(keys: "⌥⌘B", title: "书签管理器"),
            ]),
            .init(name: "工具", symbol: "wrench", shortcuts: [
                .init(keys: "⌥⌘C", title: "开发者工具"),
                .init(keys: "⌥⌘I", title: "开发者工具（检查）"),
                .init(keys: "⌥⌘J", title: "JavaScript 控制台"),
                .init(keys: "⌘Y", title: "历史记录"),
                .init(keys: "⇧⌘⌫", title: "清除浏览数据"),
            ]),
            .init(name: "窗口", symbol: "macwindow", shortcuts: [
                .init(keys: "⌘N", title: "新建窗口"),
                .init(keys: "⇧⌘N", title: "无痕窗口"),
                .init(keys: "⌘H", title: "隐藏 Chrome"),
                .init(keys: "⌥⌘H", title: "隐藏其他"),
            ]),
        ]

        // ---------- Firefox ----------
        r["org.mozilla.firefox"] = [
            .init(name: "标签页", symbol: "rectangle.stack", shortcuts: [
                .init(keys: "⌘T", title: "新建标签页"),
                .init(keys: "⇧⌘T", title: "重新打开关闭的标签页"),
                .init(keys: "⌘W", title: "关闭标签页"),
                .init(keys: "⌃Tab", title: "下一个标签页"),
                .init(keys: "⌃⇧Tab", title: "上一个标签页"),
            ]),
            .init(name: "导航", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⌘L", title: "聚焦到地址栏"),
                .init(keys: "⌘R", title: "重新载入"),
                .init(keys: "⌘[", title: "后退"),
                .init(keys: "⌘]", title: "转发"),
            ]),
            .init(name: "工具", symbol: "wrench", shortcuts: [
                .init(keys: "⌥⌘C", title: "Web 开发者"),
                .init(keys: "⌥⌘I", title: "检查器"),
                .init(keys: "⌥⌘J", title: "浏览器控制台"),
            ]),
        ]

        // ---------- Slack ----------
        r["com.tinyspeck.chatlyio"] = [
            .init(name: "导航", symbol: "arrow.up.arrow.down", shortcuts: [
                .init(keys: "⌘K", title: "快速切换器"),
                .init(keys: "⌘T", title: "打开话题列表"),
                .init(keys: "⌘⇧K", title: "打开私信"),
                .init(keys: "⌘⇧A", title: "打开活动"),
                .init(keys: "⌘⇧Y", title: "所有未读"),
            ]),
            .init(name: "邮件", symbol: "bubble.left", shortcuts: [
                .init(keys: "⌘/", title: "显示键盘快捷键"),
                .init(keys: "⌘.", title: "全部标为已读"),
                .init(keys: "⌥↑", title: "上一个频道"),
                .init(keys: "⌥↓", title: "下一个频道"),
                .init(keys: "⌥⇧↑", title: "上一条未读"),
                .init(keys: "⌥⇧↓", title: "下一条未读"),
            ]),
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘Z", title: "撤销"),
                .init(keys: "⌘X", title: "剪切"),
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘A", title: "全选"),
            ]),
        ]

        // ---------- Activity Monitor ----------
        r["com.apple.ActivityMonitor"] = [
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘1", title: "CPU 标签"),
                .init(keys: "⌘2", title: "内存标签"),
                .init(keys: "⌘3", title: "能源标签"),
                .init(keys: "⌘4", title: "磁盘标签"),
                .init(keys: "⌘5", title: "网络标签"),
                .init(keys: "⌃Space", title: "对进程采样"),
            ]),
            .init(name: "窗口", symbol: "macwindow", shortcuts: [
                .init(keys: "⌘0", title: "显示 Dock 图标"),
                .init(keys: "⌘N", title: "新建窗口"),
            ]),
        ]

        // ---------- System Settings ----------
        r["com.apple.systempreferences"] = [
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘F", title: "查找设置"),
                .init(keys: "⌘1-7", title: "切换分类"),
                .init(keys: "⌘L", title: "显示全部"),
            ]),
            .init(name: "窗口", symbol: "macwindow", shortcuts: [
                .init(keys: "⌘W", title: "关闭"),
                .init(keys: "⌘M", title: "最小化"),
            ]),
        ]

        // ---------- Spotlight ----------
        r["com.apple.Spotlight"] = [
            .init(name: "搜索", symbol: "magnifyingglass", shortcuts: [
                .init(keys: "⌘Space", title: "显示聚焦搜索"),
                .init(keys: "⌥⌘Space", title: "访达搜索"),
                .init(keys: "↑ ↓", title: "在结果间移动"),
                .init(keys: "↩", title: "打开结果"),
                .init(keys: "⌘↩", title: "在访达中打开"),
            ]),
        ]

        // ---------- Calculator ----------
        r["com.apple.calculator"] = [
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘V", title: "粘贴"),
                .init(keys: "⌘Z", title: "撤销"),
            ]),
            .init(name: "视图", symbol: "eye", shortcuts: [
                .init(keys: "⌘T", title: "显示磁带"),
                .init(keys: "⌥⌘T", title: "切换纸带显示"),
            ]),
        ]

        // ---------- Dictionary ----------
        r["com.apple.Dictionary"] = [
            .init(name: "编辑", symbol: "pencil", shortcuts: [
                .init(keys: "⌘C", title: "复制"),
                .init(keys: "⌘F", title: "查找"),
            ]),
        ]

        return r
    }
}
