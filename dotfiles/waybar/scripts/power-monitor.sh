#!/bin/bash

# Power consumption monitor for Waybar
# Monitors CPU and GPU power consumption

get_cpu_power() {
    # Try Intel RAPL (package power)
    if [ -r "/sys/class/powercap/intel-rapl:0/energy_uj" ]; then
        # RAPL provides energy counter, need to calculate power from energy delta
        # For simplicity, we'll use a single sample (less accurate but simpler)
        ENERGY1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
        sleep 0.1
        ENERGY2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
        if [ -n "$ENERGY1" ] && [ -n "$ENERGY2" ]; then
            ENERGY_DIFF=$((ENERGY2 - ENERGY1))
            # Power = Energy / Time (0.1s), convert from uJ to W
            POWER_W=$(awk "BEGIN {printf \"%.1f\", $ENERGY_DIFF / 100000}")
            echo "$POWER_W"
            return
        fi
    fi

    # Fallback: Try hwmon for coretemp
    for hwmon in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon/name" ] && [ "$(cat $hwmon/name)" = "coretemp" ]; then
            if [ -f "$hwmon/power1_input" ]; then
                POWER_UW=$(cat "$hwmon/power1_input")
                POWER_W=$(awk "BEGIN {printf \"%.1f\", $POWER_UW / 1000000}")
                echo "$POWER_W"
                return
            fi
        fi
    done
    echo "0"
}

get_gpu_power() {
    # Check for NVIDIA GPU
    if command -v nvidia-smi &> /dev/null; then
        GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null | head -1)
        if [ -n "$GPU_POWER" ]; then
            # Round to 1 decimal place
            GPU_POWER=$(awk "BEGIN {printf \"%.1f\", $GPU_POWER}")
            echo "$GPU_POWER"
            return
        fi
    fi

    # Check for AMD GPU
    for hwmon in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon/name" ] && [ "$(cat $hwmon/name)" = "amdgpu" ]; then
            if [ -f "$hwmon/power1_average" ]; then
                POWER_UW=$(cat "$hwmon/power1_average")
                POWER_W=$(awk "BEGIN {printf \"%.1f\", $POWER_UW / 1000000}")
                echo "$POWER_W"
                return
            fi
        fi
    done

    echo "0"
}

CPU_POWER=$(get_cpu_power)
GPU_POWER=$(get_gpu_power)

# Calculate total power using awk
TOTAL_POWER=$(awk "BEGIN {printf \"%.1f\", $CPU_POWER + $GPU_POWER}")

# Format output
if [ "$GPU_POWER" != "0" ] && [ "$CPU_POWER" != "0" ]; then
    echo "{\"text\": \"${TOTAL_POWER}W\", \"tooltip\": \"CPU: ${CPU_POWER}W | GPU: ${GPU_POWER}W\", \"class\": \"power\"}"
elif [ "$GPU_POWER" != "0" ]; then
    echo "{\"text\": \"${GPU_POWER}W\", \"tooltip\": \"GPU: ${GPU_POWER}W\", \"class\": \"power\"}"
elif [ "$CPU_POWER" != "0" ]; then
    echo "{\"text\": \"${CPU_POWER}W\", \"tooltip\": \"CPU: ${CPU_POWER}W\", \"class\": \"power\"}"
else
    echo "{\"text\": \"N/A\", \"tooltip\": \"Power monitoring unavailable\", \"class\": \"power\"}"
fi
