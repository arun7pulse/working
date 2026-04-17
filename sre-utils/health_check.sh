#!/usr/bin/env bash
# health_check.sh — HTTP endpoint health checker
# Usage: ./health_check.sh <url> [<url2> ...]
#        Exits 0 if all endpoints return HTTP 2xx, 1 otherwise.
#
# Example:
#   ./health_check.sh https://example.com https://api.example.com/health

set -euo pipefail

TIMEOUT=10
PASS=0
FAIL=0

usage() {
    echo "Usage: $0 <url> [<url2> ...]"
    exit 1
}

check_url() {
    local url="$1"
    local http_code
    http_code=$(curl -o /dev/null -s -w "%{http_code}" --max-time "$TIMEOUT" "$url" || echo "000")

    if [[ "$http_code" =~ ^2 ]]; then
        echo "[OK]   $url  (HTTP $http_code)"
        ((PASS++)) || true
    else
        echo "[FAIL] $url  (HTTP $http_code)"
        ((FAIL++)) || true
    fi
}

[[ $# -lt 1 ]] && usage

for url in "$@"; do
    check_url "$url"
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
