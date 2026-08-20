#!/bin/sh

# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Ensure we have an APP_KEY, generate one if missing (only for safety, should be in env)
if [ -z "$APP_KEY" ]; then
    echo "Warning: APP_KEY is missing. Generating a temporary one..."
    php artisan key:generate --show --no-interaction
fi

# Clear and Cache configuration for speed
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Attempt to migrate. We wrap it in a retry loop because DB might not be ready
echo "Running Database Migrations..."
php artisan migrate --force || echo "Migration failed, skipping... Check your DB_URL."

# Fix permissions again for runtime
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

echo "Starting Apache Web Server..."
# Start Apache
apache2-foreground
