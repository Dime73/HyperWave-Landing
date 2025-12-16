#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8000}"
LOG_FILE="${LOG_FILE:-/tmp/hyperwave-http.log}"
URL="http://localhost:${PORT}"

if command -v lsof >/dev/null 2>&1; then
    if lsof -iTCP:"${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
        echo "Port ${PORT} already in use; not starting another server."
    else
        nohup python3 -m http.server "${PORT}" >"${LOG_FILE}" 2>&1 &
        echo "Dev server started on ${URL} (pid $!). Logs: ${LOG_FILE}"
    fi
else
    nohup python3 -m http.server "${PORT}" >"${LOG_FILE}" 2>&1 &
    echo "Dev server started on ${URL} (pid $!). Logs: ${LOG_FILE}"
fi

open -a "Safari" "${URL}"
