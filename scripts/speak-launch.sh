#!/usr/bin/env bash
# speak launcher (fast path uses a warm daemon)
#   Super+Space / --record  → toggle push-to-talk (start/stop + clipboard)
#   Super+S     / (default) → show/hide the floating speak window
#   --prewarm               → start hidden daemon (login)
set -euo pipefail

export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH:-/usr/bin:/bin}"

SPEAK_DIR="${HOME}/workspace/speak"
SPEAK_PY="${SPEAK_DIR}/speak.py"
FULL_UI="${SPEAK_DIR}/run.sh"
LOG="${XDG_RUNTIME_DIR:-/tmp}/speak-launch.log"
CMD="${XDG_RUNTIME_DIR:-/tmp}/speak.cmd"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/speak.pid"
READY_FILE="${XDG_RUNTIME_DIR:-/tmp}/speak.ready"
TITLE_RE='^(speak|Speak)$'

MODE="ui"
case "${1:-}" in
  --record|record) MODE="record" ;;
  --prewarm|prewarm) MODE="prewarm" ;;
  --full|full) MODE="full" ;;
  --quit|quit) MODE="quit" ;;
esac

send_cmd() {
  printf '%s\n' "$1" >"$CMD"
}

daemon_alive() {
  [[ -f "$PID_FILE" ]] || return 1
  local pid
  pid="$(tr -d '[:space:]' <"$PID_FILE" 2>/dev/null || true)"
  [[ -n "${pid:-}" ]] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
}

# Prefer the uv script env python (skips `uv run` resolver on each poke).
speak_python() {
  local cand
  for cand in "${HOME}/.cache/uv/environments-v2"/speak-*/bin/python; do
    [[ -x "$cand" ]] || continue
    if "$cand" -c 'import PyQt6, sounddevice' 2>/dev/null; then
      printf '%s' "$cand"
      return 0
    fi
  done
  return 1
}

start_daemon() {
  local extra=("$@")
  if [[ ! -f "$SPEAK_PY" ]]; then
    echo "missing $SPEAK_PY" >>"$LOG"
    notify-send -u critical "speak" "speak.py not found" 2>/dev/null || true
    return 1
  fi

  {
    echo "---- $(date -Iseconds) start_daemon extra=${extra[*]-} ----"
    if py="$(speak_python)"; then
      echo "using python: $py"
      nohup "$py" "$SPEAK_PY" --daemon "${extra[@]}" >>"$LOG" 2>&1 &
    else
      echo "using uv run fallback"
      nohup uv run --script "$SPEAK_PY" --daemon "${extra[@]}" >>"$LOG" 2>&1 &
    fi
  } >>"$LOG" 2>&1
  disown 2>/dev/null || true

  local i
  for i in $(seq 1 100); do
    if daemon_alive && [[ -f "$READY_FILE" ]]; then
      return 0
    fi
    sleep 0.05
  done
  echo "daemon failed to become ready" >>"$LOG"
  return 1
}

case "$MODE" in
  prewarm)
    if daemon_alive; then
      exit 0
    fi
    rm -f "$PID_FILE" "$READY_FILE"
    start_daemon || true
    exit 0
    ;;
  quit)
    if daemon_alive; then
      send_cmd quit
    fi
    exit 0
    ;;
  record)
    if daemon_alive; then
      send_cmd toggle
      exit 0
    fi
    rm -f "$PID_FILE" "$READY_FILE"
    if start_daemon --record; then
      exit 0
    fi
    # Last resort one-shot
    if py="$(speak_python)"; then
      nohup "$py" "$SPEAK_PY" --record >>"$LOG" 2>&1 &
    else
      nohup uv run --script "$SPEAK_PY" --record >>"$LOG" 2>&1 &
    fi
    disown 2>/dev/null || true
    exit 0
    ;;
  full)
    nohup "$FULL_UI" >>"$LOG" 2>&1 &
    disown 2>/dev/null || true
    exit 0
    ;;
  ui|*)
    if ! daemon_alive; then
      rm -f "$PID_FILE" "$READY_FILE"
      start_daemon || exit 1
    fi
    ADDR=$(hyprctl clients -j 2>/dev/null | jq -r --arg re "$TITLE_RE" '
      .[] | select(.title | test($re)) | .address
    ' | head -1 || true)
    if [[ -n "${ADDR:-}" ]]; then
      FOCUSED=$(hyprctl activewindow -j | jq -r '.address // empty')
      if [[ "$FOCUSED" == "$ADDR" ]]; then
        send_cmd hide
      else
        send_cmd show
        hyprctl dispatch focuswindow "address:$ADDR" >/dev/null 2>&1 || true
      fi
    else
      send_cmd show
    fi
    exit 0
    ;;
esac
