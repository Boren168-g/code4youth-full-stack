#!/usr/bin/env bash
# Run Laravel migrations.
#
#   ./scripts/migrate.sh                 apply pending migrations
#   ./scripts/migrate.sh --fresh         drop everything and rebuild
#   ./scripts/migrate.sh --fresh --seed  rebuild and reseed
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

wait_for_mysql

if [ "${1:-}" = "--fresh" ]; then
    shift
    echo "Dropping all tables and re-running every migration."
    artisan migrate:fresh --force "$@"
else
    artisan migrate --force "$@"
fi

artisan migrate:status
