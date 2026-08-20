#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Create/Overwrite .env file to ensure Apache/PHP see the variables
echo "Syncing environment variables..."
# Capture all DB related vars and write them to .env
env | grep -E '^(APP_|DB_|FIREBASE_)' > .env

# Double check DB_URL
if [ -n "$DB_URL" ]; then
    echo "DB_URL detected. Configuring cloud connection..."
else
    echo "Warning: DB_URL is missing. Connection will likely fail."
fi

# Ensure permissions are correct
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
php artisan migrate --force || echo "Migration failed. Check DB_URL and Aiven IP Whitelist."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
