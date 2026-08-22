#!/bin/bash
# Floating WiFi panel (Omarchy-style): wifitui in a dedicated kitty window.
# Falls back to nmtui if wifitui is missing.

set -euo pipefail

CLASS="wifi-panel"
TITLE="WiFi"

WIFITUI="${HOME}/.local/bin/wifitui"
command -v wifitui >/dev/null 2>&1 && WIFITUI="$(command -v wifitui)"

# Session may export NO_COLOR=1 (disables wifitui highlights entirely).
# Force a real colorful TTY for this panel.
unset NO_COLOR
export CLICOLOR=1
export CLICOLOR_FORCE=1
export FORCE_COLOR=1
export COLORTERM=truecolor
export TERM=xterm-kitty
export WIFITUI_THEME="${WIFITUI_THEME:-$HOME/.config/wifitui/theme.toml}"

# Toggle: if panel already open, close it
if command -v hyprctl >/dev/null 2>&1; then
  existing=$(hyprctl clients -j 2>/dev/null | python3 -c "
import json,sys
try:
    clients=json.load(sys.stdin)
except Exception:
    clients=[]
for c in clients:
    if c.get('class')=='${CLASS}' or c.get('initialClass')=='${CLASS}':
        print(c.get('address','')); break
" 2>/dev/null || true)
  if [[ -n "${existing:-}" ]]; then
    hyprctl dispatch closewindow "address:${existing}" >/dev/null
    exit 0
  fi
fi

# Larger font so tab/arrow navigation is less fiddly in dialogs
KITTY_OPTS=(--class "$CLASS" --title "$TITLE" -o font_size=13 -o remember_window_size=no)

if [[ -x "$WIFITUI" ]]; then
  exec kitty "${KITTY_OPTS[@]}" -e env -u NO_COLOR \
    CLICOLOR=1 CLICOLOR_FORCE=1 FORCE_COLOR=1 COLORTERM=truecolor \
    WIFITUI_THEME="$WIFITUI_THEME" \
    "$WIFITUI" --theme "$WIFITUI_THEME" tui
fi

# Fallback
exec kitty "${KITTY_OPTS[@]}" -e bash -c \
  'nmcli device wifi list --rescan yes >/dev/null 2>&1; TERM=xterm-256color nmtui'
