#!/bin/bash

# Configuration
VENDOR_ID="1209"
PRODUCT_ID="4704"
XKB_COMMAND="xkbcomp -I\$HOME/.config/xkb \$HOME/.config/xkb/custom_layout.xkb \$DISPLAY -w 10"
DEBOUNCE_INTERVAL=10  # seconds

# Initialize log file
echo "[$(date)] Keyboard Monitor Script Started."

# Initialize debounce
LAST_RUN=0

# Function to apply keyboard layout with debounce
apply_xkb_layout() {
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_RUN))

    if [ "$TIME_DIFF" -lt "$DEBOUNCE_INTERVAL" ]; then
        echo "[$(date)] Debounce active. Skipping xkbcomp execution."
        return
    fi

    echo "[$(date)] Keyboard connected. Applying custom layout..."
    eval $XKB_COMMAND 2>&1
    if [ $? -eq 0 ]; then
        echo "[$(date)] xkbcomp executed successfully."
        LAST_RUN=$CURRENT_TIME
    else
        echo "[$(date)] xkbcomp failed."
    fi
}

# Function to handle events
handle_event() {
    EVENT_TYPE="$1"
    DEVICE_VENDOR_ID="$2"
    DEVICE_PRODUCT_ID="$3"

    if [[ "$DEVICE_VENDOR_ID" == "$VENDOR_ID" && "$DEVICE_PRODUCT_ID" == "$PRODUCT_ID" ]]; then
        if [[ "$EVENT_TYPE" == "add" ]]; then
            echo "[$(date)] Keyboard connected, applying map."
            apply_xkb_layout
        elif [[ "$EVENT_TYPE" == "remove" ]]; then
            echo "[$(date)] Keyboard disconnected."
            # Optional: Reset keyboard layout or perform other actions
        fi
    fi
}

# Start monitoring udev events
udevadm monitor --subsystem-match=usb --property --udev | while read -r line; do
    # Extract relevant properties
    if echo "$line" | grep -q "ACTION="; then
        ACTION=${line//ACTION=/}
    elif echo "$line" | grep -q "ID_VENDOR_ID="; then
        CURRENT_VENDOR_ID=${line//ID_VENDOR_ID=/}
    elif echo "$line" | grep -q "ID_MODEL_ID="; then
        CURRENT_PRODUCT_ID=${line//ID_MODEL_ID=/}
    fi

    # Once all necessary properties are captured, handle the event
    if [[ -n "$ACTION" && -n "$CURRENT_VENDOR_ID" && -n "$CURRENT_PRODUCT_ID" ]]; then
        handle_event "$ACTION" "$CURRENT_VENDOR_ID" "$CURRENT_PRODUCT_ID"

        # Reset variables for the next event
        ACTION=""
        CURRENT_VENDOR_ID=""
        CURRENT_PRODUCT_ID=""
    fi
done