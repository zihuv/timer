import AppKit
import SwiftUI

/// 应用代理
/// 负责应用生命周期管理和初始化核心组件
class AppDelegate: NSObject, NSApplicationDelegate {
    /// 倒计时管理器
    private var countdownManager: CountdownManager?

    /// 菜单栏管理器
    private var statusBarManager: StatusBarManager?

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 初始化倒计时管理器
        countdownManager = CountdownManager()

        // 初始化菜单栏管理器
        if let countdownManager = countdownManager {
            statusBarManager = StatusBarManager(countdownManager: countdownManager)
        }

        // 设置应用策略为辅助应用（无 Dock 图标）
        // 注意：还需要在 Info.plist 中设置 LSUIElement = true
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // 不在窗口关闭时终止应用
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // 不需要特殊处理
        return false
    }
}
