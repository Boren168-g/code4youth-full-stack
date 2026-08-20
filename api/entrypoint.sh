#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Sync all Render environment variables to the .env file
# We force SESSION_DRIVER to cookie to prevent 500 errors if DB connection fails
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' > .env
echo "SESSION_DRIVER=cookie" >> .env
echo "LOG_CHANNEL=stderr" >> .env

# Ensure we have an APP_KEY
if [ -z "$APP_KEY" ]; then
    echo "Warning: APP_KEY is missing. Generating a temporary one..."
    php artisan key:generate --show --no-interaction >> .env
fi

# Ensure permissions are correct
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
# We use a 3-second delay
sleep 3
php artisan migrate --force || echo "Migration failed. Check your individual DB settings in Render and Aiven IP Whitelist."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
