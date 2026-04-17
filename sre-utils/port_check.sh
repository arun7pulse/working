#!/usr/bin/env bash
# port_check.sh — TCP port reachability checker
# Usage: ./port_check.sh <host:port> [<host2:port2> ...]
#        Exits 0 if all ports are reachable, 1 otherwise.
#
# Example:
#   ./port_check.sh db.internal:5432 cache.internal:6379 app.internal:8080

set -euo pipefail

TIMEOUT=5
PASS=0
FAIL=0

usage() {
    echo "Usage: $0 <host:port> [<host2:port2> ...]"
    exit 1
}

check_port() {
    local target="$1"
    local host port
    host="${target%%:*}"
    port="${target##*:}"

    if [[ -z "$host" || -z "$port" ]]; then
        echo "[SKIP]  $target — invalid format, expected host:port"
        return
    fi

    if timeout "$TIMEOUT" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        echo "[OPEN]  $host:$port"
        ((PASS++)) || true
    else
        echo "[CLOSED] $host:$port"
        ((FAIL++)) || true
    fi
}

[[ $# -lt 1 ]] && usage

for target in "$@"; do
    check_port "$target"
done

echo ""
echo "Results: $PASS open, $FAIL closed/unreachable"
[[ $FAIL -eq 0 ]]
