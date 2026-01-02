import SwiftUI

/// 设置倒计时的 Popover 视图
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
        VStack(spacing: 20) {
            // 标题
            Text("Set Countdown")
                .font(.headline)
                .fontWeight(.semibold)

            // 时间输入
            HStack(spacing: 8) {
                // 分钟输入框
                VStack(alignment: .leading, spacing: 4) {
                    Text("Min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("25", text: $minutes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                }

                // 分隔符
                Text(":")
                    .font(.system(size: 20, weight: .medium))
                    .padding(.top, 12)

                // 秒数输入框
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sec")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("00", text: $seconds)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 70)
                        .multilineTextAlignment(.center)
                }
            }

            // 错误提示
            if showError {
                Text("Please enter valid time values")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            // 按钮
            HStack(spacing: 12) {
                // 取消按钮
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                .frame(minWidth: 80)

                // 开始按钮
                Button("Start") {
                    startCountdown()
                }
                .buttonStyle(.borderedProminent)
                .frame(minWidth: 80)
            }

            Spacer()
        }
        .padding()
        .frame(width: 220, height: 180)
        .onAppear {
            // 重置错误状态
            showError = false
        }
    }

    // MARK: - 私有方法

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

        // 关闭 Popover
        presentationMode.wrappedValue.dismiss()
    }
}

/// 预览
struct SettingsPopover_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPopover(countdownManager: CountdownManager())
    }
}
