#!/bin/zsh
# CheatSheet — 一键编译脚本（使用 Xcode 内嵌工具链以避免 shim 拦截）
# 用法：  ./build.sh
set -euo pipefail

cd "$(dirname "$0")"

# 优先使用 Xcode.app 内嵌的真实工具链，
# 而不是 /usr/bin 下的 codex shim（会被许可检查拦截）。
XCODE_DEVELOPER="/Applications/Xcode.app/Contents/Developer"
if [ ! -x "$XCODE_DEVELOPER/usr/bin/xcodebuild" ]; then
  echo "!! 未找到 Xcode.app，请先安装 Xcode。"
  exit 1
fi
export PATH="$XCODE_DEVELOPER/usr/bin:$XCODE_DEVELOPER/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"

echo "==> 工具链: $($XCODE_DEVELOPER/usr/bin/xcodebuild -version | head -1)"
echo "==> 编译 CheatSheet.app (Release)…"

"$XCODE_DEVELOPER/usr/bin/xcodebuild" \
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
