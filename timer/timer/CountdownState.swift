import Foundation

/// 倒计时状态枚举
enum CountdownStatus {
    case idle        // 未设置倒计时
    case running     // endTime > now
    case finished    // endTime <= now
}

/// 倒计时状态模型
/// 核心设计：使用 endTime: Date 作为唯一真实数据源
struct CountdownState {
    var endTime: Date?

    /// 当前状态
    var status: CountdownStatus {
        guard let endTime = endTime else { return .idle }
        return endTime > Date() ? .running : .finished
    }

    /// 剩余时间（秒）
    var remainingTime: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return max(0, endTime.timeIntervalSinceNow)
    }
}
