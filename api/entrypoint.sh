#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# We force certain env vars for Render production environment
export LOG_CHANNEL=stderr
export SESSION_DRIVER=cookie
export DB_CONNECTION=mysql

# Sync Render environment variables to the .env file
# This is crucial so that both Artisan (CLI) and Apache/PHP-FPM see the same config
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' > .env
echo "LOG_CHANNEL=stderr" >> .env
echo "SESSION_DRIVER=cookie" >> .env

# Ensure permissions are correct for storage and bootstrap/cache
# In production containers, we often need to ensure the web user can write here
echo "Setting up directories and permissions..."
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
# If this fails, it's usually because Aiven doesn't have 0.0.0.0/0 whitelisted or password is wrong
php artisan migrate --force || echo "Migration failed. Verify your Aiven DB_URL/Password and IP Whitelist."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
