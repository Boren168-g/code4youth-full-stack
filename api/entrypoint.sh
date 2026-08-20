#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Ensure we have an APP_KEY for the web server
if [ -z "$APP_KEY" ]; then
    echo "Warning: APP_KEY is missing. Generating one..."
    export APP_KEY=$(php artisan key:generate --show --no-interaction)
fi

# IMPORTANT: We DO NOT run php artisan config:cache here.
# Caching environment variables on Render causes them to be "frozen" at the wrong values.

# Clear any old cache just in case
php artisan config:clear
php artisan route:clear

# Ensure permissions are correct for production
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
php artisan migrate --force || echo "Migration failed. Check DB_URL or individual DB vars in Render."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
