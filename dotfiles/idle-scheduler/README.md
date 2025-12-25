# Idle Scheduler

A beautiful TUI-based idle inhibitor scheduler for Hyprland that automatically manages `hypridle` based on time schedules.

## Features

- **Time-based scheduling**: Set specific times when idle should be inhibited
- **Day-of-week support**: Configure different schedules for different days
- **Beautiful TUI**: Interactive terminal interface using `gum`
- **Waybar integration**: Shows current status with schedule info
- **Manual override**: Toggle idle inhibit manually when needed
- **Automatic daemon**: Runs in background managing hypridle

## Components

- `idle-scheduler-daemon.sh` - Background daemon that monitors schedules
- `idle-scheduler-config.sh` - TUI for managing schedules
- `idle-scheduler.sh` (Waybar) - Status display and quick controls

## Usage

### Opening the TUI

- **Keyboard**: `Super + Shift + I`
- **Waybar**: Right-click the idle inhibitor icon
- **Terminal**: Run `~/.config/nix/dotfiles/idle-scheduler/idle-scheduler-config.sh`

### TUI Interface

The TUI provides these options:

1. **Add schedule** - Create new time-based schedule
2. **Edit schedule** - Modify existing schedule times
3. **Toggle schedule** - Enable/disable schedules
4. **Delete schedule** - Remove schedules
5. **Manual override** - Take manual control

### Waybar Button

- **Left click**: Toggle manual override (inhibit on/off)
- **Right click**: Open TUI configuration

### Creating a Schedule

1. Open the TUI
2. Select "Add schedule"
3. Enter:
   - Name (e.g., "Work Hours")
   - Start time (HH:MM format, e.g., "09:00")
   - End time (HH:MM format, e.g., "17:00")
   - Days (select with Space, confirm with Enter)

### Example Schedules

**Work Hours (no sleep during work)**
- Name: Work Hours
- Time: 09:00 - 17:00
- Days: Mon, Tue, Wed, Thu, Fri

**Movie Night**
- Name: Movie Night
- Time: 20:00 - 23:00
- Days: Fri, Sat

**Gaming Sessions**
- Name: Gaming
- Time: 19:00 - 01:00 (overnight schedule)
- Days: Sat, Sun

## How It Works

1. **Daemon** checks your schedules every 30 seconds
2. If current time matches any enabled schedule:
   - Kills `hypridle` (prevents system sleep)
   - Sets inhibit state to active
3. When schedule ends:
   - Restarts `hypridle`
   - System can sleep normally
4. **Manual override** disables schedule control until you turn it off

## Configuration Files

All configs stored in `~/.config/idle-scheduler/`:

- `schedules.conf` - Schedule definitions (format: enabled|name|start|end|days)
- `state` - Current state (manual_override, inhibit_active)
- `daemon.log` - Daemon activity log

## Systemd Service

The daemon runs as a systemd user service:

```bash
# Check status
systemctl --user status idle-scheduler

# View logs
journalctl --user -u idle-scheduler -f

# Restart
systemctl --user restart idle-scheduler
```

## Troubleshooting

### TUI doesn't open
- Check if gum is installed: `which gum`
- Install if missing: `nix-env -iA nixpkgs.gum`

### Schedules not working
- Check daemon status: `systemctl --user status idle-scheduler`
- View daemon log: `cat ~/.config/idle-scheduler/daemon.log`
- Ensure manual override is OFF in the TUI

### Waybar button not showing
- Reload Waybar: `Super + Shift + R`
- Check script is executable: `ls -la ~/.config/waybar/scripts/idle-scheduler.sh`

## Schedule File Format

The schedule file uses pipe-delimited format:

```
enabled|name|start_time|end_time|days
true|Work Hours|09:00|17:00|1,2,3,4,5
false|Weekend Gaming|14:00|02:00|6,7
```

- **enabled**: `true` or `false`
- **name**: Display name
- **start_time**: HH:MM format (24-hour)
- **end_time**: HH:MM format (24-hour, can be < start for overnight)
- **days**: Comma-separated day numbers (1=Mon, 7=Sun)

## Tips

- Use **overnight schedules** for events that span midnight (end < start)
- Use **manual override** when you need temporary control
- **Disable schedules** instead of deleting if you want to reuse them later
- Check the **daemon log** if schedules aren't working as expected
