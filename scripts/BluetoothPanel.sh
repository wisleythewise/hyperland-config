#!/bin/bash
# Floating Bluetooth panel (Omarchy-style): bluetui in a dedicated kitty window.
# Falls back to bluetoothctl if bluetui is missing.

set -euo pipefail

CLASS="bt-panel"
TITLE="Bluetooth"

BLUETUI="${HOME}/.local/bin/bluetui"
command -v bluetui >/dev/null 2>&1 && BLUETUI="$(command -v bluetui)"

# Session may export NO_COLOR=1 — strip it so the TUI can highlight focus.
unset NO_COLOR
export CLICOLOR=1
export CLICOLOR_FORCE=1
export FORCE_COLOR=1
export COLORTERM=truecolor
export TERM=xterm-kitty

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

# Slightly larger font so tabs/fields are easier to hit
KITTY_OPTS=(--class "$CLASS" --title "$TITLE" -o font_size=13 -o remember_window_size=no)

if [[ -x "$BLUETUI" ]]; then
  exec kitty "${KITTY_OPTS[@]}" -e env -u NO_COLOR \
    CLICOLOR=1 CLICOLOR_FORCE=1 FORCE_COLOR=1 COLORTERM=truecolor \
    "$BLUETUI"
fi

# Fallback: interactive bluetoothctl
exec kitty "${KITTY_OPTS[@]}" -e env -u NO_COLOR bluetoothctl
