import Foundation

/// 倒计时状态枚举
enum CountdownStatus {
    case idle        // 未设置倒计时
    case running     // 运行中
    case paused      // 暂停状态
    case finished    // 已完成
}

/// 倒计时状态模型
/// 核心设计：使用 endTime: Date 作为唯一真实数据源
struct CountdownState {
    var endTime: Date?
    var lastDuration: TimeInterval?  // 上次设置的时长（用于 reset）
    var isPaused: Bool = false       // 是否暂停
    var pausedAt: Date?              // 暂停时间点

    /// 当前状态
    var status: CountdownStatus {
        guard let endTime = endTime else { return .idle }
        if isPaused { return .paused }
        return endTime > Date() ? .running : .finished
    }

    /// 剩余时间（秒）
    var remainingTime: TimeInterval? {
        guard let endTime = endTime else { return nil }
        if isPaused, let pausedAt = pausedAt {
            // 使用 ceil 向上取整，避免因时序差异导致显示少一秒
            return ceil(max(0, endTime.timeIntervalSince(pausedAt)))
        }
        return max(0, endTime.timeIntervalSinceNow)
    }
}
