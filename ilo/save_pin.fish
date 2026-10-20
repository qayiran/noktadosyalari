#!/usr/bin/env fish

set SAVE_DIR "$HOME/sitelen/pinlër"
mkdir -p $SAVE_DIR

# 🧠 We have to calculate the timestamp OUTSIDE the quotes!
set TIMESTAMP (date +%Y%m%d_%H%M%S)
set DEST "$SAVE_DIR/pin_$TIMESTAMP.jpg"

cp /tmp/pinterest_widget.jpg $DEST

notify-send -t 2000 "Pin Kayd edildi! 💖" "$DEST"
