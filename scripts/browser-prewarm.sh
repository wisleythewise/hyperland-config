#!/bin/bash
# Pre-warm Chromium on startup to eliminate cold-start delay
# The snap sandbox and squashfs decompression happens once, then stays cached

sleep 5  # Wait for desktop to settle

# Start chromium headless briefly to warm up the snap
chromium --headless --disable-gpu --no-sandbox --remote-debugging-port=9222 &
CHROME_PID=$!

# Give it time to fully initialize
sleep 8

# Kill the headless instance
kill $CHROME_PID 2>/dev/null

exit 0
