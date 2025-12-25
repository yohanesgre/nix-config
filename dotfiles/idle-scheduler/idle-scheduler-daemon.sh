#!/usr/bin/env bash
# Idle Scheduler Daemon
# Manages hypridle based on time-based schedules

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/idle-scheduler"
CONFIG_FILE="$CONFIG_DIR/schedules.conf"
STATE_FILE="$CONFIG_DIR/state"
LOG_FILE="$CONFIG_DIR/daemon.log"

mkdir -p "$CONFIG_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize state file
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "manual_override=false" > "$STATE_FILE"
        echo "inhibit_active=false" >> "$STATE_FILE"
    fi
}

# Get current state
get_state() {
    local key="$1"
    grep "^${key}=" "$STATE_FILE" 2>/dev/null | cut -d= -f2
}

# Set state
set_state() {
    local key="$1"
    local value="$2"

    if grep -q "^${key}=" "$STATE_FILE" 2>/dev/null; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$STATE_FILE"
    else
        echo "${key}=${value}" >> "$STATE_FILE"
    fi
}

# Check if current time is within any schedule
should_inhibit() {
    [[ ! -f "$CONFIG_FILE" ]] && return 1

    local current_day=$(date +%u)  # 1-7 (Mon-Sun)
    local current_time=$(date +%H:%M)
    local current_epoch=$(date +%s)

    while IFS='|' read -r enabled name start_time end_time days; do
        [[ "$enabled" != "true" ]] && continue
        [[ -z "$start_time" || -z "$end_time" || -z "$days" ]] && continue

        # Check if current day is in schedule
        if [[ ! "$days" =~ $current_day ]]; then
            continue
        fi

        # Convert times to epoch for comparison
        local start_epoch=$(date -d "$start_time" +%s 2>/dev/null || echo 0)
        local end_epoch=$(date -d "$end_time" +%s 2>/dev/null || echo 0)
        local today_epoch=$(date -d "00:00" +%s)
        local current_seconds=$((current_epoch - today_epoch))
        local start_seconds=$((start_epoch - today_epoch))
        local end_seconds=$((end_epoch - today_epoch))

        # Handle overnight schedules (end time < start time)
        if [[ $end_seconds -lt $start_seconds ]]; then
            if [[ $current_seconds -ge $start_seconds || $current_seconds -le $end_seconds ]]; then
                log "Schedule '$name' active (overnight: $start_time-$end_time)"
                return 0
            fi
        else
            if [[ $current_seconds -ge $start_seconds && $current_seconds -le $end_seconds ]]; then
                log "Schedule '$name' active ($start_time-$end_time)"
                return 0
            fi
        fi
    done < "$CONFIG_FILE"

    return 1
}

# Kill hypridle
kill_hypridle() {
    if systemctl --user is-active --quiet hypridle.service; then
        log "Stopping hypridle"
        systemctl --user stop hypridle.service
        sleep 0.5
    fi
}

# Start hypridle
start_hypridle() {
    if ! systemctl --user is-active --quiet hypridle.service; then
        log "Starting hypridle"
        systemctl --user start hypridle.service
    fi
}

# Apply inhibit state
apply_inhibit_state() {
    local should_inhibit_now="$1"

    if [[ "$should_inhibit_now" == "true" ]]; then
        kill_hypridle
        set_state "inhibit_active" "true"
    else
        start_hypridle
        set_state "inhibit_active" "false"
    fi
}

# Main loop
main() {
    log "Idle scheduler daemon started"
    init_state

    # Initial state
    local last_inhibit_state="unknown"

    while true; do
        local manual_override=$(get_state "manual_override")

        if [[ "$manual_override" == "true" ]]; then
            # Manual override is active - don't change anything
            sleep 30
            continue
        fi

        # Check schedule
        local current_inhibit="false"
        if should_inhibit; then
            current_inhibit="true"
        fi

        # Only apply changes if state changed
        if [[ "$current_inhibit" != "$last_inhibit_state" ]]; then
            log "State change: inhibit=$current_inhibit"
            apply_inhibit_state "$current_inhibit"
            last_inhibit_state="$current_inhibit"
        fi

        # Check every 30 seconds
        sleep 30
    done
}

# Handle signals
trap 'log "Daemon stopped"; exit 0' SIGTERM SIGINT

main
