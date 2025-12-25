# Migration Plan: swayidle/swaylock → hypridle/hyprlock (REVISED)

## Overview
Migrate from swayidle/swaylock to hypridle/hyprlock to fix NVIDIA suspend/resume issues and improve Hyprland integration.

## Why This Migration?
- **Fix NVIDIA resume issues**: hyprlock doesn't have the keyboard input freeze bug that swaylock has after resume
- **Better Hyprland integration**: Native tools designed specifically for Hyprland
- **Restore security**: Can re-enable locking before suspend (currently disabled due to swaylock bugs)
- **Active maintenance**: Part of the Hyprland ecosystem with ongoing development

---

## Configuration Approach

**Using Approach A: Pure Nix/home-manager configuration**

We'll use home-manager modules (`services.hypridle` and `programs.hyprlock`) to generate the configurations. This provides:
- Declarative configuration
- Version control via Nix
- Automatic config generation
- Integration with home-manager

The `dotfiles/hypridle/hypridle.conf` file that already exists is for reference only and won't be used.

---

## Files to Modify

### 1. `hyprland.nix`

#### a. **Lines 7-23: DELETE swaylock-restart-after-resume service**
Remove the entire systemd service - it's obsolete with hyprlock.

**DELETE:**
```nix
  # Systemd user services for swaylock restart after resume (NVIDIA fix)
  systemd.user.services = {
    # Kill and restart swaylock after system resume to fix frozen lock screen
    swaylock-restart-after-resume = {
      Unit = {
        Description = "Restart swaylock after system resume";
        After = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 1 && pkill swaylock; sleep 0.3 && WAYLAND_DISPLAY=wayland-1 swaylock -f &'";
      };
      Install = {
        WantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
      };
    };
  };
```

#### b. **After line 6: ADD hypridle and hyprlock configuration**

**ADD:**
```nix
  # Hypridle - idle management daemon for Hyprland
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
          timeout = 1800;  # 30 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 2700;  # 45 minutes
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 3600;  # 60 minutes
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # Hyprlock - screen lock for Hyprland
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

#### c. **Line 155: KEEP idle-scheduler autostart**
**NO CHANGE NEEDED** - Keep this line as-is:
```nix
"systemctl --user start idle-scheduler.service"
```
The idle-scheduler daemon will manage hypridle based on time schedules.

#### d. **Line 244: UPDATE lock keybind**
Change from:
```nix
"$mainMod SHIFT, L, exec, swaylock -f"
```
To:
```nix
"$mainMod SHIFT, L, exec, hyprlock"
```

#### e. **Lines 336-339: DELETE old swayidle/swaylock config references**
**DELETE:**
```nix
# Swayidle configuration
".config/swayidle/config".source = ./dotfiles/swayidle/config;

# Swaylock configuration
".config/swaylock/config".source = ./dotfiles/swaylock/config;
```

These configs are no longer needed since hypridle and hyprlock are managed by home-manager.

---

### 2. `dotfiles/idle-scheduler/idle-scheduler-daemon.sh`

**Lines 85-105: Replace swayidle functions with hypridle**

Change from:
```bash
# Kill swayidle
kill_swayidle() {
    if pgrep -x swayidle > /dev/null; then
        log "Killing swayidle"
        pkill -x swayidle
        sleep 0.5
    fi
}

# Start swayidle
start_swayidle() {
    if ! pgrep -x swayidle > /dev/null; then
        log "Starting swayidle"
        local config="${XDG_CONFIG_HOME:-$HOME/.config}/swayidle/config"
        if [[ -f "$config" ]]; then
            swayidle -w -C "$config" &
        else
            swayidle -w &
        fi
    fi
}
```

To:
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

**Lines 107-118: Update function calls**

Change from:
```bash
# Apply inhibit state
apply_inhibit_state() {
    local should_inhibit_now="$1"

    if [[ "$should_inhibit_now" == "true" ]]; then
        kill_swayidle
        set_state "inhibit_active" "true"
    else
        start_swayidle
        set_state "inhibit_active" "false"
    fi
}
```

To:
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

**Line 3: Update comment**

Change from:
```bash
# Manages swayidle based on time-based schedules
```

To:
```bash
# Manages hypridle based on time-based schedules
```

---

### 3. `dotfiles/idle-scheduler/idle-scheduler-config.sh`

**Lines 287-291: Replace swayidle with hypridle**

Change from:
```bash
            # Kill or start swayidle
            if [[ "$new_state" == "true" ]]; then
                pkill -x swayidle
            else
                swayidle -w &
            fi
```

To:
```bash
            # Kill or start hypridle
            if [[ "$new_state" == "true" ]]; then
                pkill -x hypridle
            else
                hypridle &
            fi
```

---

### 4. `dotfiles/waybar/scripts/idle-scheduler.sh`

**Lines 15-36: Replace swayidle with hypridle**

Change from:
```bash
# Toggle manual override
toggle_manual() {
    local current=$(get_state "manual_override")
    local current_inhibit=$(get_state "inhibit_active")

    if [[ "$current" == "true" ]]; then
        # Turn off manual override - let schedule take over
        echo "manual_override=false" > "$STATE_FILE"
        echo "inhibit_active=false" >> "$STATE_FILE"

        # Restart swayidle
        pkill -x swayidle
        sleep 0.3
        swayidle -w &
    else
        # Turn on manual override and inhibit
        echo "manual_override=true" > "$STATE_FILE"
        echo "inhibit_active=true" >> "$STATE_FILE"

        # Kill swayidle
        pkill -x swayidle
    fi
}
```

To:
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

---

### 5. `dotfiles/systemd/idle-scheduler.service`

**Line 3: Update documentation**

Change from:
```ini
Documentation=Manages swayidle based on time schedules
```

To:
```ini
Documentation=Manages hypridle based on time schedules
```

---

### 6. `dotfiles/wlogout/layout`

**Line 3: Change swaylock → hyprlock**

Change from:
```json
{
    "label" : "lock",
    "action" : "swaylock -f",
    "text" : "Lock",
    "keybind" : "l"
}
```

To:
```json
{
    "label" : "lock",
    "action" : "hyprlock",
    "text" : "Lock",
    "keybind" : "l"
}
```

---

### 7. `dotfiles/idle-scheduler/README.md`

**Update all swayidle references to hypridle:**

- Line 3: `swayidle` → `hypridle`
- Line 12: `swayidle` → `hypridle`
- Line 74: `swayidle` → `hypridle`
- Line 77: `swayidle` → `hypridle`

Update the description at line 3 from:
```markdown
A beautiful TUI-based idle inhibitor scheduler for Hyprland that automatically manages `swayidle` based on time schedules.
```

To:
```markdown
A beautiful TUI-based idle inhibitor scheduler for Hyprland that automatically manages `hypridle` based on time schedules.
```

---

### 8. `README.md` (Main README)

**Lines 218-221: Update directory references**

Change from:
```markdown
    ├── swaylock/               # Screen locker
    │   └── config
    ├── swayidle/               # Idle manager
    │   └── config
```

To:
```markdown
    ├── hypridle/               # Idle manager (config for reference)
    │   └── hypridle.conf       # (actual config managed by home-manager)
    ├── hyprlock/               # Screen locker (managed by home-manager)
```

Or simply remove these lines since the configs are now managed by Nix.

---

## Summary of Changes

### Files Modified (8):
1. ✅ `hyprland.nix` - Major changes:
   - Remove swaylock-restart service
   - Add hypridle service config
   - Add hyprlock program config
   - Update lock keybind
   - Remove old config file copies

2. ✅ `dotfiles/idle-scheduler/idle-scheduler-daemon.sh` - Replace swayidle → hypridle

3. ✅ `dotfiles/idle-scheduler/idle-scheduler-config.sh` - Replace swayidle → hypridle

4. ✅ `dotfiles/waybar/scripts/idle-scheduler.sh` - Replace swayidle → hypridle

5. ✅ `dotfiles/systemd/idle-scheduler.service` - Update description

6. ✅ `dotfiles/wlogout/layout` - Replace swaylock → hyprlock

7. ✅ `dotfiles/idle-scheduler/README.md` - Update documentation

8. ✅ `README.md` - Update directory structure docs

### Files to Keep for Reference:
- `dotfiles/hypridle/hypridle.conf` - Reference only (home-manager generates actual config)
- `dotfiles/swayidle/config` - Can be deleted after successful migration
- `dotfiles/swaylock/config` - Can be deleted after successful migration

---

## Migration Steps

### Step 1: Backup Current Configuration
```bash
# Create a git commit before migration
cd ~/.config/nix
git add -A
git commit -m "Pre-migration backup: swayidle/swaylock state"

# Or create a migration branch
git checkout -b migrate-hypridle
```

### Step 2: Apply All Changes
Make all the modifications listed above to the 8 files.

### Step 3: Build and Switch
```bash
# Test the configuration build
home-manager build

# If build succeeds, switch
home-manager switch
```

### Step 4: Logout and Login
```bash
# Logout from Hyprland
# Login again to start fresh session
```

### Step 5: Verify Services
```bash
# Check if hypridle is running
pgrep -x hypridle

# Check if idle-scheduler daemon is running
systemctl --user status idle-scheduler.service

# Check home-manager generated configs
ls -la ~/.config/hypr/hypridle.conf
ls -la ~/.config/hypr/hyprlock.conf
```

---

## Testing Plan

### Quick Test Mode (Optional)
For faster testing, you can temporarily modify the timeouts in `hyprland.nix`:

```nix
listener = [
  {
    timeout = 30;      # 30 seconds (for testing)
    on-timeout = "hyprctl dispatch dpms off";
    on-resume = "hyprctl dispatch dpms on";
  }
  {
    timeout = 60;      # 60 seconds (for testing)
    on-timeout = "loginctl lock-session";
  }
  {
    timeout = 90;      # 90 seconds (for testing)
    on-timeout = "systemctl suspend";
  }
];
```

After testing, revert to production timeouts (1800, 2700, 3600).

### Test Cases

#### 1. Manual Lock Test
```bash
# Press Super+Shift+L
# Expected: hyprlock shows with Material Design theme
# Expected: Time/date displayed correctly
# Expected: Password input works
# Expected: Unlock works
```

#### 2. Idle Lock Test
Wait for timeout (45 min or 60 sec in test mode):
- Expected: Screen locks automatically
- Expected: hyprlock appears

#### 3. Suspend/Resume Test
```bash
systemctl suspend
# Wake up the system
# Expected: System locked before suspend
# Expected: hyprlock appears after resume
# Expected: Keyboard input works (no freeze!)
```

#### 4. Idle Scheduler Toggle Test
```bash
# Click idle-scheduler icon in Waybar
# Expected: hypridle stops (icon changes)
# Click again
# Expected: hypridle starts (icon changes back)
```

#### 5. Wlogout Test
```bash
# Press Super+Escape
# Click "Lock"
# Expected: hyprlock appears
```

#### 6. Display Off Test
Wait for display timeout (30 min or 30 sec in test mode):
- Expected: Display turns off
- Expected: Display turns back on when moving mouse/keyboard

---

## Rollback Plan

If migration fails:

### Option 1: Git Revert
```bash
# If you committed before migration
git revert HEAD

# Or if you used a branch
git checkout master
```

### Option 2: Manual Rollback
```bash
# Revert hyprland.nix changes
# Restore swaylock-restart service
# Restore swayidle/swaylock home.file entries
# Update scripts back to swayidle

# Then rebuild
home-manager switch
```

---

## Post-Migration Cleanup (Optional)

After successful migration and testing:

```bash
# Remove old config files
rm -rf dotfiles/swayidle/
rm -rf dotfiles/swaylock/

# Keep hypridle.conf for reference or remove it
# rm dotfiles/hypridle/hypridle.conf

# Commit the migration
git add -A
git commit -m "Migrate from swayidle/swaylock to hypridle/hyprlock

- Fix NVIDIA resume keyboard freeze issue
- Enable locking before suspend
- Use native Hyprland tools
- Manage configs via home-manager"
```

---

## Key Improvements Over Original Plan

1. ✅ **Clarified configuration approach** - Using pure Nix/home-manager (no duplicate configs)
2. ✅ **Added missing files** - idle-scheduler-config.sh, README files
3. ✅ **Fixed systemd description format** - Single-line format
4. ✅ **Removed ambiguity** - Clear about keeping idle-scheduler autostart
5. ✅ **Simplified hypridle commands** - Just `hypridle` with no flags
6. ✅ **Added quick test mode** - For faster validation
7. ✅ **Complete file list** - All 8 files that need changes
8. ✅ **Clear migration steps** - Step-by-step process
9. ✅ **Better rollback plan** - Multiple rollback options

---

## Notes

- **NVIDIA fix**: hyprlock properly handles resume without keyboard freezing
- **Security restored**: Locking before suspend now enabled (was disabled due to swaylock bugs)
- **Material Design**: Theme colors and style preserved from swaylock
- **Grace period**: 2 seconds maintained
- **Timeouts**: All match previous configuration (30/45/60 minutes)
- **Idle scheduler**: Still manages hypridle based on time schedules via daemon
- **Manual override**: Waybar toggle still works to disable/enable hypridle
