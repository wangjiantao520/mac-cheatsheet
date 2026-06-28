#!/bin/zsh
# CheatSheet — 一键编译脚本
# 用法：  ./build.sh
# 本地：自动用 `xcode-select -p` 指向的 Xcode 工具链
# CI  ：GitHub Actions runner 上同样可用（macOS runner 自带 Xcode）
set -euo pipefail

cd "$(dirname "$0")"

# 1. 解析当前激活的 Xcode（CI 和本地都用同一套逻辑）
XCODE_DEV="$(xcode-select -p)"
if [ ! -x "$XCODE_DEV/usr/bin/xcodebuild" ]; then
  echo "!! 没找到可用的 xcodebuild（xcode-select 指向：$XCODE_DEV）"
  echo "   本地请安装 Xcode 并运行：sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi
export PATH="$XCODE_DEV/usr/bin:$XCODE_DEV/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"

echo "==> Xcode 工具链: $($XCODE_DEV/usr/bin/xcodebuild -version | head -1)"
echo "==> 编译 CheatSheet.app (Release)…"

"$XCODE_DEV/usr/bin/xcodebuild" \
  -project CheatSheet.xcodeproj \
  -scheme CheatSheet \
  -configuration Release \
  -derivedDataPath build \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="build/Build/Products/Release/CheatSheet.app"
if [ -d "$APP_PATH" ]; then
  echo ""
  echo "✅ 构建成功: $APP_PATH"
  echo "   启动: open '$APP_PATH'"
  SIZE=$(du -sh "$APP_PATH" | awk '{print $1}')
  echo "   大小: $SIZE"
else
  echo "!! 构建失败"
  exit 1
fi
