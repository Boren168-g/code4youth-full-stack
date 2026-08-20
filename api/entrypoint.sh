#!/bin/sh
# Exit on error
set -e

echo "Starting Code4Youth API Setup..."

# Sync all Render environment variables to the .env file
env | grep -E '^(APP_|DB_|FIREBASE_|MYSQL_)' > .env

# Ensure permissions are correct
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Run migrations
echo "Running Database Migrations..."
# We use a 5-second delay to ensure the DB is ready
sleep 5
php artisan migrate --force || echo "Migration failed. Check your individual DB settings in Render."

echo "Starting Apache Web Server on Port $PORT..."
exec apache2-foreground
