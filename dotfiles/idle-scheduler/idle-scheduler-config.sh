#!/usr/bin/env bash
# Idle Scheduler Configuration TUI
# Beautiful terminal interface for managing idle inhibit schedules

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/idle-scheduler"
CONFIG_FILE="$CONFIG_DIR/schedules.conf"
STATE_FILE="$CONFIG_DIR/state"

mkdir -p "$CONFIG_DIR"

# Colors for gum
BLUE="#89b4fa"
GREEN="#a6e3a1"
RED="#f38ba8"
YELLOW="#f9e2af"
MAUVE="#cba6f7"

# Day names mapping
declare -A DAY_NAMES=(
    [1]="Monday" [2]="Tuesday" [3]="Wednesday" [4]="Thursday"
    [5]="Friday" [6]="Saturday" [7]="Sunday"
)

# Initialize config file if it doesn't exist
init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        touch "$CONFIG_FILE"
    fi
}

# Get state value
get_state() {
    local key="$1"
    grep "^${key}=" "$STATE_FILE" 2>/dev/null | cut -d= -f2
}

# Set state value
set_state() {
    local key="$1"
    local value="$2"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo "${key}=${value}" > "$STATE_FILE"
    elif grep -q "^${key}=" "$STATE_FILE" 2>/dev/null; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$STATE_FILE"
    else
        echo "${key}=${value}" >> "$STATE_FILE"
    fi
}

# Format days for display
format_days() {
    local days="$1"
    local result=""

    for day in $(echo "$days" | sed 's/,/ /g'); do
        if [[ -n "${DAY_NAMES[$day]}" ]]; then
            result+="${DAY_NAMES[$day]:0:3} "
        fi
    done

    echo "$result" | sed 's/ $//'
}

# List all schedules
list_schedules() {
    gum style --border rounded --padding "1 2" --border-foreground "$BLUE" \
        "📅 Idle Inhibit Schedules"
    echo ""

    if [[ ! -s "$CONFIG_FILE" ]]; then
        gum style --foreground "$YELLOW" "No schedules configured yet."
        return
    fi

    local line_num=0
    while IFS='|' read -r enabled name start_time end_time days; do
        line_num=$((line_num + 1))
        local status_icon="✓"
        local status_color="$GREEN"

        if [[ "$enabled" != "true" ]]; then
            status_icon="✗"
            status_color="$RED"
        fi

        local days_formatted=$(format_days "$days")

        gum style --border rounded --padding "0 1" --margin "0 1" \
            "$(gum style --foreground "$status_color" "[$status_icon]") $(gum style --bold --foreground "$MAUVE" "$name")" \
            "    Time: $(gum style --foreground "$BLUE" "$start_time - $end_time")" \
            "    Days: $(gum style --foreground "$GREEN" "$days_formatted")"
    done < "$CONFIG_FILE"
}

# Add new schedule
add_schedule() {
    gum style --border rounded --padding "1 2" --border-foreground "$GREEN" \
        "➕ Add New Schedule"
    echo ""

    local name=$(gum input --placeholder "Schedule name (e.g., 'Work Hours')" --prompt "> " --width 50)
    [[ -z "$name" ]] && return

    local start_time=$(gum input --placeholder "Start time (HH:MM, e.g., 09:00)" --prompt "> " --width 30)
    [[ -z "$start_time" ]] && return

    local end_time=$(gum input --placeholder "End time (HH:MM, e.g., 17:00)" --prompt "> " --width 30)
    [[ -z "$end_time" ]] && return

    echo ""
    gum style --foreground "$BLUE" "Select days (use Space to select, Enter to confirm):"

    local selected_days=$(gum choose --no-limit \
        "1:Monday" "2:Tuesday" "3:Wednesday" "4:Thursday" \
        "5:Friday" "6:Saturday" "7:Sunday")

    [[ -z "$selected_days" ]] && return

    # Extract day numbers
    local day_numbers=$(echo "$selected_days" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')

    # Append to config
    echo "true|$name|$start_time|$end_time|$day_numbers" >> "$CONFIG_FILE"

    gum style --foreground "$GREEN" "✓ Schedule added successfully!"
    sleep 1
}

# Edit schedule
edit_schedule() {
    if [[ ! -s "$CONFIG_FILE" ]]; then
        gum style --foreground "$YELLOW" "No schedules to edit."
        sleep 1
        return
    fi

    local schedules=()
    local line_num=0
    while IFS='|' read -r enabled name start_time end_time days; do
        line_num=$((line_num + 1))
        local days_formatted=$(format_days "$days")
        schedules+=("$line_num:$name ($start_time-$end_time, $days_formatted)")
    done < "$CONFIG_FILE"

    local selected=$(gum choose "${schedules[@]}")
    [[ -z "$selected" ]] && return

    local selected_num=$(echo "$selected" | cut -d: -f1)

    # Get the schedule line
    local schedule_line=$(sed -n "${selected_num}p" "$CONFIG_FILE")
    IFS='|' read -r enabled name start_time end_time days <<< "$schedule_line"

    echo ""
    gum style --border rounded --padding "1 2" --border-foreground "$BLUE" \
        "✏️  Edit Schedule: $name"
    echo ""

    local new_name=$(gum input --placeholder "Name" --prompt "> " --value "$name" --width 50)
    local new_start=$(gum input --placeholder "Start time (HH:MM)" --prompt "> " --value "$start_time" --width 30)
    local new_end=$(gum input --placeholder "End time (HH:MM)" --prompt "> " --value "$end_time" --width 30)

    # Update the line
    local new_line="$enabled|$new_name|$new_start|$new_end|$days"
    # Escape special characters for sed
    local escaped_line=$(echo "$new_line" | sed 's/[\/&]/\\&/g')
    sed -i "${selected_num}s/.*/$escaped_line/" "$CONFIG_FILE"

    gum style --foreground "$GREEN" "✓ Schedule updated!"
    sleep 1
}

# Toggle schedule enabled/disabled
toggle_schedule() {
    if [[ ! -s "$CONFIG_FILE" ]]; then
        gum style --foreground "$YELLOW" "No schedules to toggle."
        sleep 1
        return
    fi

    local schedules=()
    local line_num=0
    while IFS='|' read -r enabled name start_time end_time days; do
        line_num=$((line_num + 1))
        local status="[OFF]"
        [[ "$enabled" == "true" ]] && status="[ON]"
        schedules+=("$line_num:$status $name")
    done < "$CONFIG_FILE"

    local selected=$(gum choose "${schedules[@]}")
    [[ -z "$selected" ]] && return

    local selected_num=$(echo "$selected" | cut -d: -f1)

    # Toggle enabled state
    local schedule_line=$(sed -n "${selected_num}p" "$CONFIG_FILE")
    IFS='|' read -r enabled name start_time end_time days <<< "$schedule_line"

    local new_enabled="false"
    [[ "$enabled" == "false" ]] && new_enabled="true"

    local new_line="$new_enabled|$name|$start_time|$end_time|$days"
    # Escape special characters for sed
    local escaped_line=$(echo "$new_line" | sed 's/[\/&]/\\&/g')
    sed -i "${selected_num}s/.*/$escaped_line/" "$CONFIG_FILE"

    local status_msg="disabled"
    [[ "$new_enabled" == "true" ]] && status_msg="enabled"

    gum style --foreground "$GREEN" "✓ Schedule $status_msg!"
    sleep 1
}

# Delete schedule
delete_schedule() {
    if [[ ! -s "$CONFIG_FILE" ]]; then
        gum style --foreground "$YELLOW" "No schedules to delete."
        sleep 1
        return
    fi

    local schedules=()
    local line_num=0
    while IFS='|' read -r enabled name start_time end_time days; do
        line_num=$((line_num + 1))
        schedules+=("$line_num:$name")
    done < "$CONFIG_FILE"

    local selected=$(gum choose "${schedules[@]}")
    [[ -z "$selected" ]] && return

    local selected_num=$(echo "$selected" | cut -d: -f1)
    local schedule_name=$(echo "$selected" | cut -d: -f2-)

    if gum confirm "Delete schedule '$schedule_name'?"; then
        sed -i "${selected_num}d" "$CONFIG_FILE"
        gum style --foreground "$GREEN" "✓ Schedule deleted!"
        sleep 1
    fi
}

# Manual override control
manage_override() {
    local current_override=$(get_state "manual_override")
    local current_inhibit=$(get_state "inhibit_active")

    gum style --border rounded --padding "1 2" --border-foreground "$MAUVE" \
        "🔧 Manual Override"
    echo ""

    local override_status="OFF"
    local inhibit_status="Inactive"

    [[ "$current_override" == "true" ]] && override_status="ON"
    [[ "$current_inhibit" == "true" ]] && inhibit_status="Active"

    gum style --foreground "$BLUE" \
        "Manual Override: $override_status" \
        "Current Inhibit State: $inhibit_status"
    echo ""

    local choice=$(gum choose \
        "Enable manual override (disable schedule)" \
        "Disable manual override (enable schedule)" \
        "Toggle inhibit manually" \
        "Back")

    case "$choice" in
        "Enable manual override"*)
            set_state "manual_override" "true"
            gum style --foreground "$GREEN" "✓ Manual override enabled"
            sleep 1
            ;;
        "Disable manual override"*)
            set_state "manual_override" "false"
            gum style --foreground "$GREEN" "✓ Manual override disabled - schedule will take effect"
            sleep 1
            ;;
        "Toggle inhibit manually")
            local new_state="true"
            [[ "$current_inhibit" == "true" ]] && new_state="false"

            set_state "manual_override" "true"
            set_state "inhibit_active" "$new_state"

            # Kill or start hypridle
            if [[ "$new_state" == "true" ]]; then
                systemctl --user stop hypridle.service
            else
                systemctl --user start hypridle.service
            fi

            gum style --foreground "$GREEN" "✓ Inhibit toggled manually"
            sleep 1
            ;;
    esac
}

# Main menu
main_menu() {
    while true; do
        clear

        gum style --bold --foreground "$MAUVE" --border double --padding "1 2" \
            "⏰ Idle Scheduler Configuration"
        echo ""

        list_schedules
        echo ""

        local choice=$(gum choose \
            "➕ Add schedule" \
            "✏️  Edit schedule" \
            "🔄 Toggle schedule on/off" \
            "❌ Delete schedule" \
            "🔧 Manual override" \
            "🚪 Exit")

        case "$choice" in
            "➕ Add schedule")
                clear
                add_schedule
                ;;
            "✏️  Edit schedule")
                clear
                edit_schedule
                ;;
            "🔄 Toggle schedule on/off")
                clear
                toggle_schedule
                ;;
            "❌ Delete schedule")
                clear
                delete_schedule
                ;;
            "🔧 Manual override")
                clear
                manage_override
                ;;
            "🚪 Exit")
                clear
                gum style --foreground "$GREEN" "👋 Goodbye!"
                exit 0
                ;;
        esac
    done
}

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed"
    echo "Please install it with: nix-env -iA nixpkgs.gum"
    exit 1
fi

init_config
main_menu
