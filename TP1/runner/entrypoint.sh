#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_URL:?GITHUB_URL is required (repo/org URL)}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is required (registration token)}"

RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux,x64}"

cleanup() {
  if [ -f .runner ]; then
    ./config.sh remove --unattended --token "$GITHUB_TOKEN" || true
  fi
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

if [ ! -f .runner ]; then
  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$GITHUB_TOKEN" \
    --name "$RUNNER_NAME" \
    --work "$RUNNER_WORKDIR" \
    --labels "$RUNNER_LABELS" \
    --unattended \
    --replace
fi

cleanup_old() {
  # Best effort; token may expire before shutdown.
  ./config.sh remove --unattended --token "$GITHUB_TOKEN" || true
}

./run.sh &
RUNNER_PID=$!
wait $RUNNER_PID || true
cleanup_old
