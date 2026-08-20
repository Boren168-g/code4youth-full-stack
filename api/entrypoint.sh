#!/bin/sh

# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Ensure we have an APP_KEY, generate one if missing
if [ -z "$APP_KEY" ]; then
    echo "Warning: APP_KEY is missing from environment variables."
    # We generate one if it's missing just to allow it to boot,
    # but the user SHOULD add it to Render settings.
    export APP_KEY=$(php artisan key:generate --show --no-interaction)
    echo "Generated temporary key: $APP_KEY"
fi

# We skip config/route/view caching for now to avoid "View path not found" errors
# on first boot. We only do basic setup.

# Attempt to migrate.
echo "Running Database Migrations..."
# This might fail if DB_URL is not set or DB is starting up.
# We don't exit if it fails so the app can still boot.
php artisan migrate --force || echo "Migration failed. This is expected if DB_URL is not set."

# Ensure permissions are correct for storage and cache
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "Starting Apache Web Server..."
# Start Apache
apache2-foreground
