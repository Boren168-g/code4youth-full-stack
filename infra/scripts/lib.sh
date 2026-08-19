#!/usr/bin/env bash
# Shared helpers. Sourced by the other scripts, not run directly.
set -euo pipefail

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$INFRA_DIR"

if [ ! -f .env ]; then
    echo "infra/.env is missing. Copy .env.example to .env first." >&2
    exit 1
fi

set -a
source .env
set +a

# `podman compose` (delegates to Docker Compose v2) has much better spec
# coverage than the standalone podman-compose Python tool. Prefer it, but
# fall back so teammates with either one installed are not blocked.
if podman compose version >/dev/null 2>&1; then
    COMPOSE="podman compose"
elif command -v podman-compose >/dev/null 2>&1; then
    COMPOSE="podman-compose"
    echo "note: using podman-compose; 'depends_on: condition' may be ignored." >&2
else
    echo "Neither 'podman compose' nor 'podman-compose' was found." >&2
    exit 1
fi

# Local helper scripts always target the development stack. Deployments use
# compose.yml directly and never inherit local bind mounts or phpMyAdmin.
COMPOSE_FILE="${COMPOSE_FILE:-compose.dev.yml}"

compose() { $COMPOSE -f "$COMPOSE_FILE" "$@"; }

artisan() { compose exec -T php php artisan "$@"; }

# Don't trust orchestration to sequence this — podman-compose in particular
# starts dependents before the healthcheck passes.
wait_for_mysql() {
    printf 'waiting for mysql'
    for _ in $(seq 1 60); do
        if compose exec -T mysql \
             mysqladmin ping -h 127.0.0.1 -uroot -p"$DB_ROOT_PASSWORD" --silent >/dev/null 2>&1; then
            printf ' ready.\n'
            return 0
        fi
        printf '.'
        sleep 2
    done
    printf ' timed out after 120s.\n' >&2
    echo "Check logs with: $COMPOSE logs mysql" >&2
    return 1
}
