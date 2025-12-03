#!/bin/bash
# Keep a hidden Chromium window always running on a special workspace

sleep 3

# Start chromium on a special hidden workspace
hyprctl dispatch exec "[workspace special:browser_hidden silent] chromium --new-window about:blank"
