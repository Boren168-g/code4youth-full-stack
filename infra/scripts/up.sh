#!/usr/bin/env bash
# Start the full stack. Safe to re-run.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

set -a; source .env; set +a

# PHP-FPM runs as www-data inside the container while the source tree is owned
# by the host user. These are the only Laravel paths that need container writes.
mkdir -p ../api/storage/framework/{cache,sessions,views} ../api/storage/logs ../api/bootstrap/cache
chmod -R a+rwX ../api/storage ../api/bootstrap/cache 2>/dev/null || true

compose up -d --build

wait_for_mysql

# First run only: pull PHP dependencies and generate the app key.
if [ ! -d ../api/vendor ]; then
    echo "installing composer dependencies..."
    compose exec -T php composer install --no-interaction --prefer-dist
fi

if [ -f ../api/.env ] && ! grep -q '^APP_KEY=base64:' ../api/.env; then
    artisan key:generate
fi

artisan migrate --force

echo
echo "API         http://localhost:${APP_PORT:-8000}"
echo "phpMyAdmin  http://localhost:${PMA_PORT:-8080}"
echo "MySQL       127.0.0.1:${DB_PORT_HOST:-3309}"
