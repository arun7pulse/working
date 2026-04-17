#!/usr/bin/env bash
# disk_usage.sh — Disk usage report with threshold alerting
# Usage: ./disk_usage.sh [--threshold <pct>] [--path <mount>]
#        --threshold  Alert when usage >= this percentage (default: 80)
#        --path       Check a specific mount point (default: all mounts)
#
# Example:
#   ./disk_usage.sh --threshold 90 --path /var

set -euo pipefail

THRESHOLD=80
CHECK_PATH=""

usage() {
    grep '^#' "$0" | grep -v '#!/' | sed 's/^# \{0,1\}//'
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --threshold) THRESHOLD="$2"; shift 2 ;;
        --path)      CHECK_PATH="$2"; shift 2 ;;
        --help|-h)   usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

ALERT=0

check_mount() {
    local line="$1"
    local pct use mount
    pct=$(echo "$line" | awk '{print $5}' | tr -d '%')
    use=$(echo "$line" | awk '{print $5}')
    mount=$(echo "$line" | awk '{print $6}')

    if [[ "$pct" -ge "$THRESHOLD" ]]; then
        echo "[ALERT] $mount is at $use (threshold: ${THRESHOLD}%)"
        ALERT=1
    else
        echo "[OK]    $mount is at $use"
    fi
}

if [[ -n "$CHECK_PATH" ]]; then
    line=$(df -h "$CHECK_PATH" | tail -1)
    check_mount "$line"
else
    while IFS= read -r line; do
        check_mount "$line"
    done < <(df -h | tail -n +2 | grep -v tmpfs | grep -v udev)
fi

echo ""
if [[ $ALERT -eq 1 ]]; then
    echo "WARNING: One or more mounts exceed the ${THRESHOLD}% threshold."
    exit 1
else
    echo "All mounts are within the ${THRESHOLD}% threshold."
fi
