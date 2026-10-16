#!/bin/sh
# Remove the "Open Terminal Here" Finder Quick Action.
set -eu

DEST="$HOME/Library/Services/OpenTerminalHere.workflow"

rm -rf "$DEST"
/System/Library/CoreServices/pbs -update 2>/dev/null || true

echo "Removed $DEST"
echo "Remove the remote-control lines from ~/.config/kitty/kitty.conf if they are no longer needed."
