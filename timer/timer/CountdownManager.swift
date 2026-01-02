import Combine
import Foundation

/// 倒计时管理器
/// 核心职责：
/// 1. 维护倒计时状态（使用 endTime: Date 模型）
/// 2. 每秒触发状态更新
/// 3. 提供启动/重置倒计时的方法
class CountdownManager: ObservableObject {
    /// 发布的倒计时状态
    @Published var state = CountdownState()

    /// 计时器
    private var timer: Timer?

    // MARK: - 公开方法

    /// 开始倒计时
    /// - Parameter duration: 倒计时时长（秒）
    func startCountdown(duration: TimeInterval) {
        // 设置结束时间并重新赋值整个 state 对象以触发 @Published
        state = CountdownState(endTime: Date().addingTimeInterval(duration))

        // 启动定时器
        startTimer()
    }

    /// 重置倒计时
    func resetCountdown() {
        // 重新赋值整个 state 对象以触发 @Published
        state = CountdownState(endTime: nil)
        stopTimer()
    }

    // MARK: - 私有方法

    /// 启动 1 秒定时器
    private func startTimer() {
        stopTimer() // 先停止之前的定时器

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateState()
        }
    }

    /// 停止定时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// 更新状态
    /// 检查倒计时是否完成，如果完成则停止定时器
    private func updateState() {
        // 检查是否完成
        if let remaining = state.remainingTime, remaining <= 0 {
            stopTimer()
        }

        // 重新赋值 state 以触发 @Published 更新
        // 由于 remainingTime 是计算属性，每次访问都会重新计算
        // 但我们需要触发 Combine 订阅，所以需要重新赋值整个对象
        let currentEndTime = state.endTime
        state = CountdownState(endTime: currentEndTime)
    }
}
