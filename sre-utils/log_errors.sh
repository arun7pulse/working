#!/usr/bin/env bash
# log_errors.sh — Scan log files for ERROR/WARN patterns and print a summary
# Usage: ./log_errors.sh <logfile> [<logfile2> ...] [--since <minutes>]
#        --since  Only scan lines from the last N minutes (requires syslog timestamp format)
#
# Example:
#   ./log_errors.sh /var/log/app/*.log
#   ./log_errors.sh /var/log/syslog --since 60

set -euo pipefail

SINCE_MINUTES=""
FILES=()

usage() {
    grep '^#' "$0" | grep -v '#!/' | sed 's/^# \{0,1\}//'
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --since) SINCE_MINUTES="$2"; shift 2 ;;
        --help|-h) usage ;;
        -*) echo "Unknown option: $1"; usage ;;
        *)  FILES+=("$1"); shift ;;
    esac
done

[[ ${#FILES[@]} -eq 0 ]] && usage

PATTERNS="ERROR|WARN|CRITICAL|FATAL|Exception|Traceback|panic"
TOTAL_ERRORS=0
TOTAL_WARNS=0

scan_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "[SKIP] $file — not found"
        return
    fi

    local content
    if [[ -n "$SINCE_MINUTES" ]]; then
        # Filter lines modified within the last N minutes via a temp file approach
        content=$(find "$file" -newermt "-$SINCE_MINUTES minutes" -exec cat {} \; 2>/dev/null || cat "$file")
    else
        content=$(cat "$file")
    fi

    local errors warns
    errors=$(echo "$content" | grep -cE 'ERROR|CRITICAL|FATAL|Exception|Traceback|panic' || true)
    warns=$(echo "$content"  | grep -cE 'WARN' || true)

    echo "--- $file ---"
    echo "  Errors/Critical : $errors"
    echo "  Warnings         : $warns"

    if [[ "$errors" -gt 0 ]]; then
        echo "  Last 5 error lines:"
        echo "$content" | grep -E 'ERROR|CRITICAL|FATAL|Exception|Traceback|panic' | tail -5 | sed 's/^/    /'
    fi

    ((TOTAL_ERRORS += errors)) || true
    ((TOTAL_WARNS  += warns))  || true
}

for f in "${FILES[@]}"; do
    scan_file "$f"
done

echo ""
echo "=============================="
echo "Total errors/critical : $TOTAL_ERRORS"
echo "Total warnings        : $TOTAL_WARNS"
echo "=============================="

[[ $TOTAL_ERRORS -eq 0 ]]
