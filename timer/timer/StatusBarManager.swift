import AppKit
import Combine
import SwiftUI

/// 菜单栏管理器
/// 核心职责：
/// 1. 创建和管理 NSStatusItem
/// 2. 更新菜单栏标题
/// 3. 处理菜单点击事件
/// 4. 显示设置 Popover
class StatusBarManager {
    /// 状态栏项
    private var statusItem: NSStatusItem?

    /// Popover
    private var popover: NSPopover?

    /// 倒计时管理器
    private let countdownManager: CountdownManager

    /// Combine 订阅
    private var cancellables = Set<AnyCancellable>()

    // MARK: - 初始化

    init(countdownManager: CountdownManager) {
        self.countdownManager = countdownManager
        setupStatusBar()
        setupMenu()
        observeStateChanges()
    }

    deinit {
        // 清理状态栏项
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }

    // MARK: - 设置

    /// 创建状态栏项
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateTitle()
    }

    /// 创建菜单
    private func setupMenu() {
        let menu = NSMenu()

        // Settings 菜单项
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Reset 菜单项
        let resetItem = NSMenuItem(
            title: "Reset",
            action: #selector(resetCountdown),
            keyEquivalent: "r"
        )
        resetItem.target = self
        menu.addItem(resetItem)

        menu.addItem(NSMenuItem.separator())

        // Quit 菜单项
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    /// 订阅状态变化
    private func observeStateChanges() {
        countdownManager.$state
            .sink { [weak self] _ in
                self?.updateTitle()
            }
            .store(in: &cancellables)
    }

    // MARK: - 更新菜单栏标题

    /// 更新菜单栏标题
    private func updateTitle() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let button = self.statusItem?.button else { return }

            switch self.countdownManager.state.status {
            case .idle:
                button.title = "⏱"
            case .running:
                if let remaining = self.countdownManager.state.remainingTime {
                    button.title = self.formatTime(remaining)
                }
            case .finished:
                button.title = "Done"
            }
        }
    }

    /// 格式化时间
    /// - Parameter interval: 时间间隔（秒）
    /// - Returns: 格式化的时间字符串
    /// - 小于 1 小时：MM:SS
    /// - 大于等于 1 小时：H:MM:SS
    private func formatTime(_ interval: TimeInterval) -> String {
        let time = Int(interval)
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - 菜单操作

    /// 显示设置 Popover
    @objc private func showSettings() {
        // 如果 Popover 已经显示，关闭它
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
            self.popover = nil
            return
        }

        // 创建新的 Popover
        let newPopover = NSPopover()
        newPopover.contentSize = NSSize(width: 220, height: 160)
        newPopover.behavior = .transient
        newPopover.contentViewController = NSHostingController(
            rootView: SettingsPopover(countdownManager: countdownManager)
        )

        // 显示 Popover
        if let button = statusItem?.button {
            newPopover.show(
                relativeTo: button.bounds,
                of: button,
                preferredEdge: .minY
            )
        }

        popover = newPopover
    }

    /// 重置倒计时
    @objc private func resetCountdown() {
        countdownManager.resetCountdown()
    }

    /// 退出应用
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
