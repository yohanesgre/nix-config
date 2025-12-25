#!/usr/bin/env bash
# Waybar Idle Scheduler Module
# Shows current idle inhibit status and schedule info

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/idle-scheduler"
STATE_FILE="$CONFIG_DIR/state"
CONFIG_FILE="$CONFIG_DIR/schedules.conf"

# Get state value
get_state() {
    local key="$1"
    grep "^${key}=" "$STATE_FILE" 2>/dev/null | cut -d= -f2
}

# Toggle manual override
toggle_manual() {
    local current=$(get_state "manual_override")
    local current_inhibit=$(get_state "inhibit_active")

    if [[ "$current" == "true" ]]; then
        # Turn off manual override - let schedule take over
        echo "manual_override=false" > "$STATE_FILE"
        echo "inhibit_active=false" >> "$STATE_FILE"

        # Restart hypridle
        systemctl --user restart hypridle.service
    else
        # Turn on manual override and inhibit
        echo "manual_override=true" > "$STATE_FILE"
        echo "inhibit_active=true" >> "$STATE_FILE"

        # Stop hypridle
        systemctl --user stop hypridle.service
    fi
}

# Open config TUI
open_config() {
    local terminal="${TERMINAL:-ghostty}"
    $terminal -e ~/.config/idle-scheduler/idle-scheduler-config.sh &
}

# Get current active schedule
get_active_schedule() {
    [[ ! -f "$CONFIG_FILE" ]] && return 1

    local current_day=$(date +%u)
    local current_time=$(date +%H:%M)
    local current_epoch=$(date +%s)

    while IFS='|' read -r enabled name start_time end_time days; do
        [[ "$enabled" != "true" ]] && continue
        [[ -z "$start_time" || -z "$end_time" || -z "$days" ]] && continue

        if [[ ! "$days" =~ $current_day ]]; then
            continue
        fi

        local start_epoch=$(date -d "$start_time" +%s 2>/dev/null || echo 0)
        local end_epoch=$(date -d "$end_time" +%s 2>/dev/null || echo 0)
        local today_epoch=$(date -d "00:00" +%s)
        local current_seconds=$((current_epoch - today_epoch))
        local start_seconds=$((start_epoch - today_epoch))
        local end_seconds=$((end_epoch - today_epoch))

        if [[ $end_seconds -lt $start_seconds ]]; then
            if [[ $current_seconds -ge $start_seconds || $current_seconds -le $end_seconds ]]; then
                echo "$name"
                return 0
            fi
        else
            if [[ $current_seconds -ge $start_seconds && $current_seconds -le $end_seconds ]]; then
                echo "$name"
                return 0
            fi
        fi
    done < "$CONFIG_FILE"

    return 1
}

# Main output for Waybar
show_status() {
    local manual_override=$(get_state "manual_override")
    local inhibit_active=$(get_state "inhibit_active")
    local active_schedule=$(get_active_schedule)

    local icon="󰾪"  # deactivated icon
    local class="deactivated"
    local tooltip="Idle inhibitor: OFF - System can sleep"

    if [[ "$inhibit_active" == "true" ]]; then
        icon="󰅶"  # activated icon
        class="activated"
        tooltip="Idle inhibitor: ON - System won't sleep"
    fi

    if [[ "$manual_override" == "true" ]]; then
        tooltip="$tooltip\n🔧 Manual override active"
        class="${class} manual"
    elif [[ -n "$active_schedule" ]]; then
        tooltip="$tooltip\n📅 Schedule: $active_schedule"
        class="${class} scheduled"
    fi

    # Output JSON for Waybar (single line for Waybar compatibility)
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$icon" "$class" "$tooltip"
}

# Handle click actions
case "$1" in
    toggle)
        toggle_manual
        ;;
    config)
        open_config
        ;;
    *)
        show_status
        ;;
esac
