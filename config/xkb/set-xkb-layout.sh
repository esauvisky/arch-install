#!/bin/bash

# Get the correct display number
export DISPLAY=$(echo $DISPLAY | grep -o ':[0-9]*')
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0  # Fallback
fi

# Get the correct XAUTHORITY
export XAUTHORITY=$(find /home/emi/.Xauthority 2>/dev/null)
if [ -z "$XAUTHORITY" ]; then
    export XAUTHORITY=/run/user/1000/gdm/Xauthority  # Alternative for GDM
fi

# Set XDG_RUNTIME_DIR
export XDG_RUNTIME_DIR="/run/user/1000"

# Ensure PATH includes standard locations
export PATH=/usr/local/bin:/usr/bin:/bin

# Debugging info
echo "Running xkbcomp with DISPLAY=$DISPLAY, XAUTHORITY=$XAUTHORITY, XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR" >> /tmp/xkb.log

# Apply keyboard layout
/usr/bin/xkbcomp -I$HOME/.config/xkb $HOME/.config/xkb/custom_layout.xkb $DISPLAY -w 10 >> /tmp/xkb.log 2>&1

echo "Done." >> /tmp/xkb.log
