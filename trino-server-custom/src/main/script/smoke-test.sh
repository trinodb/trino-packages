#!/usr/bin/env bash
#
# Smoke test for the custom tarball. Extracts the built tarball, starts the
# Trino server in daemon mode, polls /v1/info until the node reports
# state=ACTIVE, then stops the server. On timeout, dumps launcher.log and
# server.log to make the failure self-explanatory. Returns 0 only when the
# server reaches ACTIVE within the timeout.
#
# Usage: smoke-test.sh <tarball-path> <trino-version> <target-dir>
#
# Requires Java 25 on PATH (the launcher invokes it) and a free TCP port 8080.

set -euo pipefail

TARBALL=${1:?tarball path required}
VERSION=${2:?trino version required}
TARGET_DIR=${3:?target directory required}

SMOKE_DIR="${TARGET_DIR}/smoke-test"
TRINO_DIR="${SMOKE_DIR}/trino-server-custom-${VERSION}"
TIMEOUT_SECONDS=300
PORT=8080

cleanup() {
    if [ -x "${TRINO_DIR}/bin/launcher" ] && [ -f "${TRINO_DIR}/var/run/launcher.pid" ]; then
        echo "Smoke test: stopping Trino server (cleanup)"
        "${TRINO_DIR}/bin/launcher" stop || true
    fi
}
trap cleanup EXIT

echo "Smoke test: extracting ${TARBALL} to ${SMOKE_DIR}"
rm -rf "${SMOKE_DIR}"
mkdir -p "${SMOKE_DIR}"
tar -xzf "${TARBALL}" -C "${SMOKE_DIR}"

echo "Smoke test: starting Trino server in daemon mode"
"${TRINO_DIR}/bin/launcher" start

echo "Smoke test: waiting up to ${TIMEOUT_SECONDS}s for http://localhost:${PORT}/v1/info to report state=ACTIVE"
start=$(date +%s)
while true; do
    elapsed=$(( $(date +%s) - start ))
    if [ "${elapsed}" -ge "${TIMEOUT_SECONDS}" ]; then
        echo "Smoke test: timed out after ${TIMEOUT_SECONDS}s waiting for state=ACTIVE"
        echo "=== launcher.log ==="
        cat "${TRINO_DIR}/var/log/launcher.log" 2>/dev/null || echo "(launcher.log missing)"
        echo "=== server.log (last 200 lines) ==="
        tail -200 "${TRINO_DIR}/var/log/server.log" 2>/dev/null || echo "(server.log missing)"
        exit 1
    fi
    state=$(curl -sS --max-time 5 "http://localhost:${PORT}/v1/info" 2>/dev/null \
        | sed -nE 's/.*"state":"([^"]+)".*/\1/p' || true)
    if [ "${state}" = "ACTIVE" ]; then
        echo "Smoke test: Trino reached state=ACTIVE after ${elapsed}s"
        break
    fi
    sleep 2
done

echo "Smoke test: stopping Trino server"
"${TRINO_DIR}/bin/launcher" stop

echo "Smoke test: passed"
