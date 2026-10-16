#!/bin/sh
# Install the "Open Terminal Here" Finder Quick Action.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/Services/OpenTerminalHere.workflow"

rm -rf "$DEST"
mkdir -p "$DEST/Contents/Resources"
cp "$HERE/OpenTerminalHere.workflow/Contents/Info.plist" "$DEST/Contents/Info.plist"
cp "$HERE/OpenTerminalHere.workflow/Contents/Resources/document.wflow" \
   "$DEST/Contents/Resources/document.wflow"
chmod -R u+rwX,go+rX "$DEST"

/System/Library/CoreServices/pbs -update 2>/dev/null || true

cat <<'EOF'
Installed to ~/Library/Services/OpenTerminalHere.workflow

Next steps:
  1. Append kitty.conf.snippet to ~/.config/kitty/kitty.conf, then open a new
     kitty window (listen_on only takes effect at startup).
  2. Bind a shortcut:
     System Settings -> Keyboard -> Keyboard Shortcuts -> Services ->
     在当前位置打开终端
EOF
