#!/usr/bin/env bash
# Apply static Tokyo Night (night) palette across Hyprland UI + terminals.
# Safe to re-run after wallust/wallpaper so colors stay pinned.
set -euo pipefail

# Tokyo Night Night — https://github.com/folke/tokyonight.nvim
BG="#1a1b26"
BG_DARK="#16161e"
BG_HL="#292e42"
FG="#c0caf5"
FG_DARK="#a9b1d6"
COMMENT="#565f89"
BLACK="#15161e"
TERM_BLACK="#414868"
RED="#f7768e"
GREEN="#9ece6a"
YELLOW="#e0af68"
BLUE="#7aa2f7"
MAGENTA="#bb9af7"
CYAN="#7dcfff"
WHITE="#a9b1d6"
BRIGHT_WHITE="#c0caf5"
ORANGE="#ff9e64"
TEAL="#1abc9c"
BLUE0="#3d59a1"

hex_to_rgb() {
  # #rrggbb -> rr,gg,bb (decimal)
  local h="${1#\#}"
  printf "%d,%d,%d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

hex_to_rgb_space() {
  local h="${1#\#}"
  printf "%d %d %d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

BG_RGB=$(hex_to_rgb "$BG")
FG_RGB=$(hex_to_rgb "$FG")

# --- rofi (all KooL styles @import this) ---
mkdir -p "$HOME/.config/rofi/wallust"
cat > "$HOME/.config/rofi/wallust/colors-rofi.rasi" << RAS
/* Tokyo Night Night — pinned (apply-tokyonight.sh) */
* {
    active-background: ${BLUE};
    active-foreground: ${BG};
    normal-background: ${BG};
    normal-foreground: ${FG};
    urgent-background: ${RED};
    urgent-foreground: ${BG};

    alternate-active-background: ${BLUE0};
    alternate-active-foreground: ${FG};
    alternate-normal-background: ${BG_DARK};
    alternate-normal-foreground: ${FG};
    alternate-urgent-background: ${BG};
    alternate-urgent-foreground: ${FG};

    selected-active-background: ${BLUE};
    selected-active-foreground: ${BG};
    selected-normal-background: ${BLUE};
    selected-normal-foreground: ${BG};
    selected-urgent-background: ${ORANGE};
    selected-urgent-foreground: ${BG};

    background-color: ${BG};
    background: rgba(26,27,38,0.92);
    foreground: ${FG};
    border-color: ${BLUE};

    color0: ${BLACK};
    color1: ${RED};
    color2: ${GREEN};
    color3: ${YELLOW};
    color4: ${BLUE};
    color5: ${MAGENTA};
    color6: ${CYAN};
    color7: ${WHITE};
    color8: ${TERM_BLACK};
    color9: ${RED};
    color10: ${GREEN};
    color11: ${YELLOW};
    color12: ${BLUE};
    color13: ${MAGENTA};
    color14: ${CYAN};
    color15: ${BRIGHT_WHITE};
}
RAS

# --- waybar (+ wlogout imports this) ---
mkdir -p "$HOME/.config/waybar/wallust"
cat > "$HOME/.config/waybar/wallust/colors-waybar.css" << CSS
/* Tokyo Night Night — pinned (apply-tokyonight.sh) */
@define-color foreground ${FG};
@define-color background ${BG};
@define-color background-alt rgba($(hex_to_rgb "$BG"),0.35);
@define-color cursor ${BLUE};

@define-color color0 ${BLACK};
@define-color color1 ${RED};
@define-color color2 ${GREEN};
@define-color color3 ${YELLOW};
@define-color color4 ${BLUE};
@define-color color5 ${MAGENTA};
@define-color color6 ${CYAN};
@define-color color7 ${WHITE};
@define-color color8 ${TERM_BLACK};
@define-color color9 ${RED};
@define-color color10 ${GREEN};
@define-color color11 ${YELLOW};
@define-color color12 ${BLUE};
@define-color color13 ${MAGENTA};
@define-color color14 ${CYAN};
@define-color color15 ${BRIGHT_WHITE};
CSS

# --- hyprland wallust colors (hyprlock etc.) ---
mkdir -p "$HOME/.config/hypr/wallust"
cat > "$HOME/.config/hypr/wallust/wallust-hyprland.conf" << HYPR
# Tokyo Night Night — pinned (apply-tokyonight.sh)
\$background = rgb(${BG#\#})
\$foreground = rgb(${FG#\#})
\$color0 = rgb(${BLACK#\#})
\$color1 = rgb(${RED#\#})
\$color2 = rgb(${GREEN#\#})
\$color3 = rgb(${YELLOW#\#})
\$color4 = rgb(${BLUE#\#})
\$color5 = rgb(${MAGENTA#\#})
\$color6 = rgb(${CYAN#\#})
\$color7 = rgb(${WHITE#\#})
\$color8 = rgb(${TERM_BLACK#\#})
\$color9 = rgb(${RED#\#})
\$color10 = rgb(${GREEN#\#})
\$color11 = rgb(${YELLOW#\#})
\$color12 = rgb(${BLUE#\#})
\$color13 = rgb(${MAGENTA#\#})
\$color14 = rgb(${CYAN#\#})
\$color15 = rgb(${BRIGHT_WHITE#\#})
HYPR

# --- kitty theme file (also wallust target name) ---
mkdir -p "$HOME/.config/kitty/kitty-themes"
cat > "$HOME/.config/kitty/kitty-themes/TokyoNight.conf" << KITTY
# Tokyo Night Night
foreground ${FG}
background ${BG}
cursor ${FG}
cursor_text_color ${BG}
selection_foreground ${FG}
selection_background ${BG_HL}

color0  ${BLACK}
color1  ${RED}
color2  ${GREEN}
color3  ${YELLOW}
color4  ${BLUE}
color5  ${MAGENTA}
color6  ${CYAN}
color7  ${WHITE}
color8  ${TERM_BLACK}
color9  ${RED}
color10 ${GREEN}
color11 ${YELLOW}
color12 ${BLUE}
color13 ${MAGENTA}
color14 ${CYAN}
color15 ${BRIGHT_WHITE}

active_tab_foreground   ${BG}
active_tab_background   ${BLUE}
inactive_tab_foreground ${COMMENT}
inactive_tab_background ${BG_DARK}
active_border_color     ${BLUE}
inactive_border_color   ${TERM_BLACK}
bell_border_color       ${ORANGE}
url_color               ${CYAN}
KITTY
cp -f "$HOME/.config/kitty/kitty-themes/TokyoNight.conf" \
      "$HOME/.config/kitty/kitty-themes/01-Wallust.conf"

# --- swaync color snippet (used if style imports it; also rewrite style header) ---
mkdir -p "$HOME/.config/swaync"
# Keep full style; only rewrite the :root-ish define-colors at top if present
if [[ -f "$HOME/.config/swaync/style.css" ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path.home() / ".config/swaync/style.css"
text = p.read_text()
header = """/* Tokyo Night Night — pinned (apply-tokyonight.sh) */

@define-color noti-bg rgba(26, 27, 38, 0.96);
@define-color noti-bg-alt rgba(22, 22, 30, 0.96);
@define-color text-color #c0caf5;
@define-color text-dim #565f89;
@define-color border-color #3d59a1;
@define-color accent #7aa2f7;
@define-color accent-alt #bb9af7;
@define-color urgent #f7768e;

"""
import re
# Strip previous define-color block at start (and our header)
body = re.sub(
    r"^(?:/\* Tokyo Night.*?\*/\s*)?(?:@define-color[^\n]+\n)+\s*",
    "",
    text,
    count=1,
    flags=re.S,
)
# Also handle "Clean minimal" comment-only starts
body = re.sub(r"^/\* Clean minimal swaync style \*/\s*", "", body)
# Replace hard-coded greys in close button etc. lightly via defines where possible
body = body.replace("background: #444444;", "background: #414868;")
body = body.replace("background: #666666;", "background: #7aa2f7;")
p.write_text(header + body)
print("swaync style updated")
PY
fi

echo "Tokyo Night palette applied."
