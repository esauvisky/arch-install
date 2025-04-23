#!/bin/bash

# --- Configuration ---
# Base directory for mount points. Ensure this directory exists.
# Use an absolute path. Using ~/ expands to the home dir of the user running the script.
MOUNT_BASE_DIR="/home/emi/Files/Android Mounts"
# Path to your adbfs script/binary
ADBFS_SCRIPT="adbfs-devspecific.sh"
# Additional options for adbfs (e.g., allow_other requires fuse.conf setup)
#ADBFS_OPTS="-o allow_other"
ADBFS_OPTS=""
# Log file
LOG_FILE="/tmp/adb-mount-manager.log"
# --- End Configuration ---

# Associative array to store mounted devices (serial -> mountpoint)
declare -A mounted_devices

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to mount a device
mount_device() {
    local serial="$1"
    # Check if already mounted by this script
    if [[ -v mounted_devices["$serial"] ]]; then
        #log "Device $serial already tracked as mounted at ${mounted_devices["$serial"]}"
        return 0
    fi

    local mount_point="$MOUNT_BASE_DIR/$serial"
    log "Attempting to mount device $serial at $mount_point"

    # Check if mount point exists but is not mounted (stale mount?)
    if mountpoint -q "$mount_point"; then
        log "WARN: Mount point $mount_point is already mounted (possibly stale). Skipping mount."
        # Add to tracking to potentially unmount later if device disappears
        mounted_devices["$serial"]="$mount_point"
        return 1
    fi

    # Create mount point directory if it doesn't exist
    mkdir -p "$mount_point"
    if [[ $? -ne 0 ]]; then
        log "ERROR: Failed to create directory $mount_point"
        return 1
    fi

    # Run adbfs in the background
    log "Executing: $ADBFS_SCRIPT $ADBFS_OPTS -D \"$serial\" \"$mount_point\""
    "$ADBFS_SCRIPT" $ADBFS_OPTS -D "$serial" "$mount_point" >> "$LOG_FILE" 2>&1 &
    local adbfs_pid=$!

    # Give FUSE a moment to mount
    sleep 2

    # Check if mount was successful
    if mountpoint -q "$mount_point"; then
        log "SUCCESS: Device $serial mounted at $mount_point (PID: $adbfs_pid)"
        mounted_devices["$serial"]="$mount_point"
        return 0
    else
        log "ERROR: Failed to mount device $serial at $mount_point. Check adbfs output."
        # Clean up directory if empty
        rmdir "$mount_point" 2>/dev/null
        # Ensure the background process is killed if it's still running
        if ps -p $adbfs_pid > /dev/null; then
           log "Killing potentially lingering adbfs process $adbfs_pid for $serial"
           kill $adbfs_pid
        fi
        return 1
    fi
}

# Function to unmount a device
unmount_device() {
    local serial="$1"
    if [[ ! -v mounted_devices["$serial"] ]]; then
        #log "Device $serial is not tracked as mounted. Skipping unmount."
        return 0
    fi

    local mount_point="${mounted_devices["$serial"]}"
    log "Attempting to unmount device $serial from $mount_point"

    # Check if it's actually mounted before trying to unmount
    if ! mountpoint -q "$mount_point"; then
        log "WARN: Mount point $mount_point for device $serial is not mounted. Cleaning up tracking."
        unset mounted_devices["$serial"]
        # Attempt to remove directory if it exists and is empty
        rmdir "$mount_point" 2>/dev/null
        return 1
    fi

    # Unmount using fusermount (preferred for FUSE)
    fusermount -u -z "$mount_point" # -z for lazy unmount
    local umount_status=$?
    sleep 1 # Give it a moment

    if [[ $umount_status -eq 0 ]] || ! mountpoint -q "$mount_point"; then
        log "SUCCESS: Unmounted $mount_point for device $serial"
        unset mounted_devices["$serial"]
        # Remove the mount point directory
        rmdir "$mount_point"
        if [[ $? -ne 0 ]]; then
           log "WARN: Could not remove directory $mount_point (maybe not empty?)"
        fi
        return 0
    else
        log "ERROR: Failed to unmount $mount_point for device $serial (fusermount exit code: $umount_status)."
        # You might want to leave it tracked so it doesn't try mounting again over the failed mount
        return 1
    fi
}

# Function to reconcile current devices with tracked mounts
reconcile_mounts() {
    log "Reconciling mounts..."
    declare -A current_devices # Associative array for current devices in 'device' state

    # Get current list of devices
    while read -r line; do
        # Skip empty lines or header lines
        [[ -z "$line" ]] && continue
        [[ "$line" == "List of devices attached" ]] && continue

        # Parse serial and state
        local serial state
        serial=$(echo "$line" | awk '{print $1}')
        state=$(echo "$line" | awk '{print $2}')

        if [[ "$state" == "device" ]]; then
            current_devices["$serial"]=1
        fi
    done < <(adb devices)

    # Mount devices that are connected but not mounted
    for serial in "${!current_devices[@]}"; do
        if [[ ! -v mounted_devices["$serial"] ]]; then
            log "Device $serial detected, attempting mount."
            mount_device "$serial"
        fi
    done

    # Unmount devices that are tracked but no longer connected/authorized
    # Iterate over a copy of keys, as unmount_device modifies the array
    local mounted_keys=("${!mounted_devices[@]}")
    for serial in "${mounted_keys[@]}"; do
        if [[ ! -v current_devices["$serial"] ]]; then
            log "Device $serial no longer detected or not in 'device' state, attempting unmount."
            unmount_device "$serial"
        fi
    done
    log "Reconciliation finished."
}

# --- Main Execution ---

# Ensure base directory exists
mkdir -p "$MOUNT_BASE_DIR"
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to create base mount directory $MOUNT_BASE_DIR. Exiting." >&2
    exit 1
fi

log "Starting ADB Mount Manager."
log "Base directory: $MOUNT_BASE_DIR"
log "ADBFS script: $ADBFS_SCRIPT"
log "ADBFS options: $ADBFS_OPTS"

# Cleanup function on exit
cleanup() {
    log "Received exit signal. Cleaning up mounts..."
    local mounted_keys=("${!mounted_devices[@]}")
    for serial in "${mounted_keys[@]}"; do
        unmount_device "$serial"
    done
    log "ADB Mount Manager stopped."
    exit 0
}

# Trap signals for cleanup
trap cleanup SIGINT SIGTERM SIGHUP

# Initial reconciliation
reconcile_mounts

# Monitor device changes using adb track-devices
# The pipe means the 'while read' loop runs in a subshell, so
# changes to mounted_devices won't persist outside.
# Workaround: Run the reconciliation logic within the loop or use process substitution.
log "Starting ADB device tracking..."
adb track-devices | while read -r line; do
    # Any output from track-devices indicates a potential change. Re-check everything.
    log "Change detected via track-devices: [$line]"
    reconcile_mounts
done

# If the loop exits (e.g., adb server killed), perform cleanup
log "ADB track-devices stream ended."
cleanup
