#!/bin/bash
# Timer 应用启动脚本

APP_PATH="$(dirname "$0")/timer.app"

if [ ! -d "$APP_PATH" ]; then
    echo "错误：找不到 timer.app"
    exit 1
fi

echo "正在启动 Timer 应用..."
open "$APP_PATH"
