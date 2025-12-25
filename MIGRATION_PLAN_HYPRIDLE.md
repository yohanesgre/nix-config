# Migration Plan: swayidle/swaylock → hypridle/hyprlock

## Overview
Migrate from swayidle/swaylock to hypridle/hyprlock to fix NVIDIA suspend/resume issues and improve Hyprland integration.

## Why This Migration?
- **Fix NVIDIA resume issues**: hyprlock doesn't have the keyboard input freeze bug that swaylock has after resume
- **Better Hyprland integration**: Native tools designed specifically for Hyprland
- **Restore security**: Can re-enable locking before suspend (currently disabled due to swaylock bugs)
- **Active maintenance**: Part of the Hyprland ecosystem with ongoing development

---

## Files to Create

### 1. `/home/yohanes/.config/nix/dotfiles/hypridle/hypridle.conf`
```conf
# Hypridle configuration for Hyprland
# Material Design idle management

general {
    lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances
    before_sleep_cmd = loginctl lock-session    # lock before suspend
    after_sleep_cmd = hyprctl dispatch dpms on  # turn on display after resume
    ignore_dbus_inhibit = false                 # respect inhibitors
}

# Listener 1: Turn off display after 30 minutes (1800 seconds)
listener {
    timeout = 1800
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

# Listener 2: Lock screen after 45 minutes (2700 seconds)
listener {
    timeout = 2700
    on-timeout = loginctl lock-session
}

# Listener 3: Suspend system after 1 hour (3600 seconds)
listener {
    timeout = 3600
    on-timeout = systemctl suspend
}
```

### 2. `/home/yohanes/.config/nix/dotfiles/hyprlock/hyprlock.conf`
```conf
# Material Design Hyprlock Configuration
# Beautiful lock screen with Material Design colors

general {
    disable_loading_bar = false
    hide_cursor = true
    grace = 2
    no_fade_in = false
    no_fade_out = false
}

# Background - wallpaper with blur
background {
    monitor =
    path = ~/.config/hypr/wallpapers/pexels-simon73-1183099.jpg
    blur_passes = 3
    blur_size = 7
    brightness = 0.8
    contrast = 0.9
}

# Time
label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%H:%M")"
    color = rgb(255, 255, 255)
    font_size = 90
    font_family = Inter
    position = 0, 200
    halign = center
    valign = center
}

# Date
label {
    monitor =
    text = cmd[update:60000] echo "$(date +"%A, %B %e")"
    color = rgb(255, 255, 255)
    font_size = 24
    font_family = Inter
    position = 0, 100
    halign = center
    valign = center
}

# Input field - Material Design style
input-field {
    monitor =
    size = 300, 50
    outline_thickness = 3
    dots_size = 0.25
    dots_spacing = 0.3
    dots_center = true

    # Material Design Blue (#2196F3)
    outer_color = rgba(33, 150, 243, 0.7)
    inner_color = rgba(0, 0, 0, 0.6)
    font_color = rgb(255, 255, 255)

    # Verifying state (Material Blue)
    check_color = rgb(33, 150, 243)

    # Wrong password state (Material Red #F44336)
    fail_color = rgb(244, 67, 54)
    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>

    # Caps lock warning (Material Amber #FFC107)
    capslock_color = rgb(255, 193, 7)

    fade_on_empty = true
    fade_timeout = 1000

    placeholder_text = <span foreground="##FFFFFF99">Enter password...</span>

    position = 0, -100
    halign = center
    valign = center
}

# User label
label {
    monitor =
    text = $USER
    color = rgb(255, 255, 255)
    font_size = 16
    font_family = Inter
    position = 0, -170
    halign = center
    valign = center
}
```

---

## Files to Modify

### 3. `dotfiles/idle-scheduler/idle-scheduler-daemon.sh`

**Lines 85-105:** Change `swayidle` → `hypridle`
```bash
# Kill hypridle
kill_hypridle() {
    if pgrep -x hypridle > /dev/null; then
        log "Killing hypridle"
        pkill -x hypridle
        sleep 0.5
    fi
}

# Start hypridle
start_hypridle() {
    if ! pgrep -x hypridle > /dev/null; then
        log "Starting hypridle"
        hypridle &
    fi
}
```

**Lines 107-118:** Update function calls
```bash
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
```

### 4. `dotfiles/waybar/scripts/idle-scheduler.sh`

**Lines 15-36:** Change `swayidle` → `hypridle`
```bash
# Toggle manual override
toggle_manual() {
    local current=$(get_state "manual_override")
    local current_inhibit=$(get_state "inhibit_active")

    if [[ "$current" == "true" ]]; then
        # Turn off manual override - let schedule take over
        echo "manual_override=false" > "$STATE_FILE"
        echo "inhibit_active=false" >> "$STATE_FILE"

        # Restart hypridle
        pkill -x hypridle
        sleep 0.3
        hypridle &
    else
        # Turn on manual override and inhibit
        echo "manual_override=true" > "$STATE_FILE"
        echo "inhibit_active=true" >> "$STATE_FILE"

        # Kill hypridle
        pkill -x hypridle
    fi
}
```

### 5. `dotfiles/systemd/idle-scheduler.service`

**Line 3:** Update description
```ini
Description=Idle Scheduler Daemon
Documentation=Manages hypridle based on time schedules
```

### 6. `dotfiles/wlogout/layout`

**Line 3:** Change swaylock → hyprlock
```json
{
    "label" : "lock",
    "action" : "hyprlock",
    "text" : "Lock",
    "keybind" : "l"
}
```

### 7. `hyprland.nix`

#### a. DELETE lines 7-23 (swaylock-restart-after-resume service)
Remove the entire `swaylock-restart-after-resume` service - it's obsolete with hyprlock.

#### b. ADD after line 6 (before closing `lib.mkIf isLinux {`):
```nix
  # Hypridle - idle management daemon
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          timeout = 1800;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 2700;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 3600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # Hyprlock - screen lock
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor = true;
        grace = 2;
        no_fade_in = false;
        no_fade_out = false;
      };

      background = [{
        monitor = "";
        path = "~/.config/hypr/wallpapers/pexels-simon73-1183099.jpg";
        blur_passes = 3;
        blur_size = 7;
        brightness = 0.8;
        contrast = 0.9;
      }];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgb(255, 255, 255)";
          font_size = 90;
          font_family = "Inter";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(date +"%A, %B %e")"'';
          color = "rgb(255, 255, 255)";
          font_size = 24;
          font_family = "Inter";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # User
        {
          monitor = "";
          text = "$USER";
          color = "rgb(255, 255, 255)";
          font_size = 16;
          font_family = "Inter";
          position = "0, -170";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [{
        monitor = "";
        size = "300, 50";
        outline_thickness = 3;
        dots_size = 0.25;
        dots_spacing = 0.3;
        dots_center = true;
        outer_color = "rgba(33, 150, 243, 0.7)";
        inner_color = "rgba(0, 0, 0, 0.6)";
        font_color = "rgb(255, 255, 255)";
        check_color = "rgb(33, 150, 243)";
        fail_color = "rgb(244, 67, 54)";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "rgb(255, 193, 7)";
        fade_on_empty = true;
        fade_timeout = 1000;
        placeholder_text = ''<span foreground="##FFFFFF99">Enter password...</span>'';
        position = "0, -100";
        halign = "center";
        valign = "center";
      }];
    };
  };
```

#### c. Line 244: Change keybind
```nix
"$mainMod SHIFT, L, exec, hyprlock"
```

#### d. Line 155: Remove idle-scheduler autostart (hypridle will be managed by home-manager)
DELETE: `"systemctl --user start idle-scheduler.service"`

Actually, KEEP this line - the idle-scheduler daemon is separate and manages hypridle based on schedules.

#### e. Lines 336-339: REMOVE old swayidle/swaylock config references
DELETE:
```nix
# Swayidle configuration
".config/swayidle/config".source = ./dotfiles/swayidle/config;

# Swaylock configuration
".config/swaylock/config".source = ./dotfiles/swaylock/config;
```

We don't need to manually copy configs anymore since hypridle and hyprlock are managed by home-manager modules.

---

## Summary of Changes

### New Files (2):
1. ✅ `dotfiles/hypridle/hypridle.conf` (ALREADY CREATED)
2. ⏳ `dotfiles/hyprlock/hyprlock.conf`

### Modified Files (6):
1. ⏳ `dotfiles/idle-scheduler/idle-scheduler-daemon.sh` - Replace swayidle → hypridle
2. ⏳ `dotfiles/waybar/scripts/idle-scheduler.sh` - Replace swayidle → hypridle
3. ⏳ `dotfiles/systemd/idle-scheduler.service` - Update description
4. ⏳ `dotfiles/wlogout/layout` - Replace swaylock → hyprlock
5. ⏳ `hyprland.nix` - Major changes:
   - Remove swaylock-restart service
   - Add hypridle service config
   - Add hyprlock program config
   - Update lock keybind
   - Remove old config file copies

---

## Testing Plan

After migration:
1. Run `home-manager switch`
2. Logout and log back in to Hyprland
3. Test manual lock: `Super+Shift+L` → should show Material Design hyprlock
4. Test idle lock: Wait 45 minutes → should lock automatically
5. Test suspend: `systemctl suspend` → should lock before suspend and unlock after resume
6. Test idle-scheduler: Toggle via Waybar → should kill/start hypridle
7. Test wlogout: Open power menu → Lock button should work

---

## Rollback Plan

If migration fails:
1. Revert changes to hyprland.nix
2. Run `home-manager switch`
3. Restore swayidle/swaylock setup
4. Update idle-scheduler scripts back to swayidle

---

## Notes

- The hypridle configuration now properly locks **before suspend** (previously disabled due to swaylock bugs)
- hyprlock uses systemd's `loginctl lock-session` for proper session locking
- Material Design theme colors preserved from swaylock
- Grace period of 2 seconds maintained
- All timeouts match previous configuration:
  - 30 min: Display off
  - 45 min: Lock screen
  - 60 min: Suspend
