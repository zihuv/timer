import SwiftUI

/// 主界面视图
struct SettingsPopover: View {
    /// 倒计时管理器
    @ObservedObject var countdownManager: CountdownManager

    /// 表示模式（用于关闭 Popover）
    @Environment(\.presentationMode) var presentationMode

    /// 分钟输入
    @State private var minutes: String = "25"

    /// 秒数输入
    @State private var seconds: String = "00"

    /// 输入错误提示
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // 当前倒计时显示
            VStack(spacing: 8) {
                Text("Current Countdown")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(displayTime)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(minWidth: 200)
            }

            Divider()

            // 时间设置区域
            VStack(spacing: 12) {
                Text("Set New Countdown")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                HStack(spacing: 12) {
                    // 分钟输入框
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("25", text: $minutes)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .multilineTextAlignment(.center)
                            .font(.system(.body, design: .rounded))
                    }

                    // 分隔符
                    Text(":")
                        .font(.system(size: 24, weight: .medium))
                        .padding(.top, 14)

                    // 秒数输入框
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sec")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("00", text: $seconds)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .multilineTextAlignment(.center)
                            .font(.system(.body, design: .rounded))
                    }
                }

                // 错误提示
                if showError {
                    Text("Please enter valid time values")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Divider()

            // 控制按钮区域
            HStack(spacing: 12) {
                // Start/Resume 按钮
                Button(action: startOrResume) {
                    Label(
                        countdownManager.state.status == .paused ? "Resume" : "Start",
                        systemImage: countdownManager.state.status == .paused ? "play.circle.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(countdownManager.state.status == .running)

                // 暂停按钮
                Button(action: pauseCountdown) {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(countdownManager.state.status != .running)

                // 重置按钮
                Button(action: resetCountdown) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(countdownManager.state.status == .idle)
            }
        }
        .padding(24)
        .frame(width: 320, height: 400)
        .onAppear {
            // 重置错误状态
            showError = false
        }
    }

    // MARK: - 计算属性

    /// 显示的时间文本
    private var displayTime: String {
        switch countdownManager.state.status {
        case .idle:
            return "--:--"
        case .running, .paused:
            if let remaining = countdownManager.state.remainingTime {
                return formatTime(remaining)
            }
            return "--:--"
        case .finished:
            return "Done!"
        }
    }

    // MARK: - 私有方法

    /// 格式化时间
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

    /// 开始倒计时
    private func startCountdown() {
        // 解析输入
        guard let min = Int(minutes),
              let sec = Int(seconds),
              min >= 0,
              sec >= 0,
              min * 60 + sec > 0 else {
            showError = true
            return
        }

        let duration = TimeInterval(min * 60 + sec)

        // 启动倒计时
        countdownManager.startCountdown(duration: duration)

        // 清除错误提示
        showError = false
    }

    /// Start 或 Resume 操作
    private func startOrResume() {
        if countdownManager.state.status == .paused {
            // 暂停状态，恢复倒计时
            countdownManager.resumeCountdown()
        } else {
            // 其他状态（idle/finished），开始新倒计时
            startCountdown()
        }
    }

    /// 暂停倒计时
    private func pauseCountdown() {
        countdownManager.pauseCountdown()
    }

    /// 重置倒计时
    private func resetCountdown() {
        countdownManager.resetCountdown()
    }
}

/// 预览
struct SettingsPopover_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPopover(countdownManager: CountdownManager())
    }
}
